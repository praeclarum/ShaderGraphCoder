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
    
    private func surfaceTest(_ surface: SGSurface) throws {
        let expectation = self.expectation(description: "Load the surface material")
        Task {
            do {
#if os(visionOS)
                // APPLE BUG: [Foundation.IO] Could not locate file 'default-binaryarchive.metallib' in bundle. Tool-hosted testing is unavailable on device destinations. Select a host application for the test target, or use a simulator destination instead.
//                let _ = try await ShaderGraphMaterial(surface: surface, geometryModifier: nil)
#endif
                let usda = surface.usda(materialName: "TestMat")
                try verifyUSDAWithModelIO(usda: usda, materialName: "TestMat")
            }
            catch {
                XCTFail("SURFACE MATERIAL ERROR: \(error)")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    private func geometryTest(_ geometryModifier: SGGeometryModifier) throws {
        let expectation = self.expectation(description: "Load the geometry material")
        Task {
            do {
#if os(visionOS)
                // APPLE BUG: [Foundation.IO] Could not locate file 'default-binaryarchive.metallib' in bundle. Tool-hosted testing is unavailable on device destinations. Select a host application for the test target, or use a simulator destination instead.
                let _ = try await ShaderGraphMaterial(surface: nil, geometryModifier: geometryModifier)
#endif
            }
            catch {
                XCTFail("GEOMETRY MATERIAL ERROR: \(error)")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    private func colorTest(_ color: SGColor) throws {
        try surfaceTest(SGPBRSurface(baseColor: color))
    }
    private func vectorTest(_ vector: SGVector) throws {
        try surfaceTest(SGPBRSurface(normal: vector))
    }
    private func scalarTest(_ scalar: SGScalar) throws {
        try surfaceTest(SGPBRSurface(opacity: scalar))
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
        Task {
            // Create the material
            let texture = SGValue.texture2DParameter(name: "ColorTexture")
            let color = texture.sample(texcoord: SGValue.uv0)
            #if os(visionOS)
            do {
                var mat = try await ShaderGraphMaterial(surface: SGPBRSurface(baseColor: color), geometryModifier: nil)
                try mat.setParameter(name: "ColorTexture", value: .textureResource(textureResource))
            }
            catch {
            }
            #endif
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
}
