import XCTest
import RealityKit
@testable import ShaderGraphCoder

final class ShaderGraphCoderTests: XCTestCase {

    private func surfaceTest(_ surface: SGSurface) throws {
        let expectation = self.expectation(description: "Load the surface material")
        Task {
            do {
#if os(visionOS)
                // APPLE BUG: [Foundation.IO] Could not locate file 'default-binaryarchive.metallib' in bundle. Tool-hosted testing is unavailable on device destinations. Select a host application for the test target, or use a simulator destination instead.
                let _ = try await ShaderGraphMaterial(surface: surface, geometryModifier: nil)
#endif
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
}
