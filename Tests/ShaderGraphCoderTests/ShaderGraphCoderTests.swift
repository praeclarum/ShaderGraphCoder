import XCTest
import RealityKit
@testable import ShaderGraphCoder

let testSurfaceShaders: [String: () -> SGSurface] = [
    "red": {
        let color: SGColor = .color3f([1, 0, 0])
        return SGPBRSurface(baseColor: color)
    },
    "pulsingBlue": {
        let frequency = SGValue.floatParameter(name: "Frequency", defaultValue: 2)
        let color: SGColor = .color3f([0, 0, 1]) * sin(SGValue.time * frequency * (2*Float.pi))
        return SGPBRSurface(baseColor: color)
    }
]

#if os(visionOS)

struct VisionTests {
    func runTests() async {
        for (tn, t) in testSurfaceShaders {
            do {
                print(tn)
                let surface = try await t()
                let _ = try await ShaderGraphMaterial(surface: surface, geometryModifier: nil)
                print("SHADER OK!")
            }
            catch {
                print("\nSHADER ERROR: \(error)\n")
                print()
            }
        }
    }
}

#endif

final class ShaderGraphCoderTests: XCTestCase {
    func testRed() throws {
        let _ = testSurfaceShaders["red"]!()
    }
    func testPulsingBlue() throws {
        let _ = testSurfaceShaders["pulsingBlue"]!()
    }
}
