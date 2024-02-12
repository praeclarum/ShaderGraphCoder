import XCTest
import RealityKit
@testable import ShaderGraphCoder

struct SGTests {
    func red() async throws -> ShaderGraphMaterial {
        let color: SGColor = .color3f([1, 0, 0])
        let surface = SGPBRSurface(baseColor: color)
        return try await ShaderGraphMaterial(surface: surface, geometryModifier: nil)
    }
    
    func pulsingBlue() async throws -> ShaderGraphMaterial {
        let frequency = SGValue.floatParameter(name: "Frequency", defaultValue: 2)
        let color: SGColor = .color3f([0, 0, 1]) * sin(SGValue.time * frequency)
        let surface = SGPBRSurface(baseColor: color)
        return try await ShaderGraphMaterial(surface: surface, geometryModifier: nil)
    }
    
    func runTests() async {
        let tests = [
//            red,
            pulsingBlue,
        ]
        for t in tests {
            do {
                let _ = try await t()
                print("SHADER OK!")
            }
            catch {
                print("\nSHADER ERROR: \(error)\n")
                print()
            }
        }
    }
}

final class ShaderGraphCoderTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
}
