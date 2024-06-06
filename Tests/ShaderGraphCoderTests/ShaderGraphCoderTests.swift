import XCTest
import RealityKit
import ModelIO
@testable import ShaderGraphCoder

final class ShaderGraphCoderTests: XCTestCase {
    
    private func verifyUSDAWithModelIO(usda: String, materialName: String) throws {
        // Write usda to a temporary URL
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.usda")
        try usda.write(to: tempURL, atomically: true, encoding: .utf8)
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        let asset = MDLAsset(url: tempURL)
        let root = asset.object(atPath: "/Root")
        XCTAssertNotNil(root, "Failed to load the USD file")
    }
    
    private func surfaceTest(_ surface: SGToken, geometryModifier: SGToken? = nil, expectErrors: Int = 0) throws {
        let expectation = self.expectation(description: "Load the surface material")
        Task {
            do {
#if os(visionOS)
                // APPLE BUG: [Foundation.IO] Could not locate file 'default-binaryarchive.metallib' in bundle. Tool-hosted testing is unavailable on device destinations. Select a host application for the test target, or use a simulator destination instead.
//                let _ = try await ShaderGraphMaterial(surface: surface, geometryModifier: nil)
#endif
                let (usda, errors) = getUSDA(materialName: "TestMat", surface: surface, geometryModifier: geometryModifier)
                if errors.count > 0 {
                    if expectErrors != errors.count {
                        XCTFail("USDA ERRORS: \(errors)")
                    }
                }
                else {
                    if expectErrors != 0 {
                        XCTFail("SHOULD HAVE PRODUCED ERRORS")
                    }
                    else {
                        try verifyUSDAWithModelIO(usda: usda, materialName: "TestMat")
                    }
                }
            }
            catch {
                XCTFail("SURFACE MATERIAL ERROR: \(error)")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    private func colorTest(_ color: SGColor) throws {
        try surfaceTest(pbrSurface(baseColor: color))
    }
    private func vectorTest(_ vector: SGVector, expectErrors: Int = 0) throws {
        try surfaceTest(pbrSurface(normal: vector), expectErrors: expectErrors)
    }
    private func scalarTest(_ scalar: SGScalar) throws {
        try surfaceTest(pbrSurface(opacity: scalar))
    }
    private func halfTest(_ scalar: SGScalar) throws {
        try surfaceTest(geometryModifier(userAttributeHalf40: .vector4h(scalar, .half(0), .half(0), .half(0))))
    }
    
    func testModulus() throws {
        try scalarTest(.float(-2.1) % .float(2))
        try colorTest(.color3f(-2.1, 0, 1.5) % .float(2))
        try vectorTest(.vector3f(-2.1, 0, 1.5) % .float(2))
        try colorTest(.color3f(-2.1, 0, 1.5) % .color3f([2, 3, 4]))
        try vectorTest(.vector3f(-2.1, 0, 1.5) % .vector3f([2, 3, 4]))
    }

    func testNormalize() throws {
        try vectorTest(normalize(.vector3f(-2.1, 0, 1.5)))
    }
    
    func testRound() throws {
        try scalarTest(round(.float(-2.1)))
        try colorTest(round(.color3f(-2.1, 0, 1.5)))
        try vectorTest(round(.vector3f(-2.1, 0, 1.5)))
    }
    
    func testSign() throws {
        try scalarTest(sign(.float(-2)))
        try colorTest(sign(.color3f(-2, 0, 1)))
        try vectorTest(sign(.vector3f(-2, 0, 1)))
    }
    
    func testRed() throws {
        try colorTest(.color3f(1, 0, 0))
    }

    func testPulsingBlue() throws {
        let frequency = SGValue.floatParameter(name: "Frequency", defaultValue: 2)
        let color: SGColor = .color3f([0, 0, 1]) * sin(SGValue.time * frequency * (2*Float.pi))
        try colorTest(color)
    }

    func testLocalTexture() throws {
        // Load the texture from a bundle resource
        guard let textureURL = Bundle.module.url(forResource: "TestTexture", withExtension: "png") else {
            throw URLError(.fileDoesNotExist)
        }
        let textureResource = try TextureResource.load(contentsOf: textureURL)
        let expectation = self.expectation(description: "Load the texture material")
        let texture = SGValue.textureParameter(name: "ColorTexture")
        let color = texture.sampleColor3f(texcoord: SGValue.uv0)
        let surface = pbrSurface(baseColor: color)
        Task {
            // Create the material
            #if os(visionOS)
//            do {
//                var mat = try await ShaderGraphMaterial(surface: surface, geometryModifier: nil)
//                try mat.setParameter(name: "ColorTexture", value: .textureResource(textureResource))
//            }
//            catch {
//            }
            #endif
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        try surfaceTest(surface)
    }
    
    func testCustomAttribute() throws {
        let pos: SGVector = .modelPosition
        let attrS: SGVector = .vector4f(pos.x * 10.0, pos.y * 10.0, pos.z * 10.0, .float(1.0))
        let geom = geometryModifier(userAttribute: attrS)
        let attr = SGValue.surfaceCustomAttribute
        let color = SGValue.color3f(attr.x, attr.y, attr.z)
        try surfaceTest(pbrSurface(baseColor: color), geometryModifier: geom)
    }
    
    func testDimError() throws {
        let v1 = SGValue.vector2f(1, 2)
        let v2 = SGValue.vector3f(3, 4, 5)
        let r = v1 + v2
        try vectorTest(r, expectErrors: 2)
    }
    
    func testTypeError() throws {
        let v1 = SGValue.vector2f(1, 2)
        let v2 = SGValue.vector3h(3, 4, 5)
        let r = v1 + v2
        try vectorTest(r, expectErrors: 2)
    }
    
    func testPropagatedError() throws {
        let v1 = SGValue.vector2f(1, 2)
        let v2 = SGValue.vector3h(3, 4, 5)
        let v3 = SGValue.vector3h(6, 7, 8)
        let r = (v1 + v2) + v3
        try vectorTest(r, expectErrors: 3)
    }
    
    func testChainHalf() throws {
        let r = SGValue.half(1).add(.half(2)).divide(.half(2))
        try halfTest(r)
    }

    func testChainVector3() throws {
        let r = SGValue.vector3f(1, 2, 3).add(.vector3f(4, 5, 6)).divide(.float(2))
        try vectorTest(r)
    }
}
