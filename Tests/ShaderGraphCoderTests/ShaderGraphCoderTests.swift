import XCTest
import RealityKit
@testable import ShaderGraphCoder

final class ShaderGraphCoderTests: XCTestCase {

    private func surfaceTest(_ surface: SGSurface) throws {
#if os(visionOS)
        let expectation = XCTestExpectation(description: "Load the materials")
        Task {
            do {
                let _ = try await ShaderGraphMaterial(surface: surface, geometryModifier: nil)
            }
            catch {
                XCTFail("MATERIAL ERROR: \(error)")
            }
        }
        expectation.fulfill()
#endif
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
