# ShaderGraphCoder

An embedded DSL to write RealityKit shaders in Swift.

**Supported Platforms:** visionOS


## Examples

```swift
// Create a solid red material for visionOS
func solidRed() async throws -> ShaderGraphMaterial {
    let color: SGColor = .color3f([1, 0, 0])
    let surface = SGPBRSurface(baseColor: color)
    return try await ShaderGraphMaterial(surface: surface, geometryModifier: nil)
}

// Create a pulsing blue material for visionOS
func pulsingBlue() async throws -> ShaderGraphMaterial {
    let frequency = SGValue.floatParameter(name: "Frequency", defaultValue: 2)
    let color: SGColor = .color3f([0, 0, 1]) * sin(SGValue.time * frequency * (2*Float.pi))
    let surface = SGPBRSurface(baseColor: color)
    return try await ShaderGraphMaterial(surface: surface, geometryModifier: nil)
}
```


## How it Works

When you write your shader code using the provided `SGValue` types, each operation on those values builds up a shader graph. The graph starts with source values (parameters, constants, and world info) and each operation extends the graph by adding nodes and edges. Each node in that graph is an operation, and each edge is a value. When you create a `ShaderGraphMaterial` from this graph, the graph is compiled into a USDA material that is then loaded by RealityKit.


## Values

The following value types are supported:

| Type | Description |
| ---- | ----------- |
| `SGValue` | Base value type |
| `SGNumeric: SGValue` | Base class for numeric types scalar, vector, and color |
| `SGScalar: SGNumeric` | A single number |
| `SGSIMD: SGNumeric` | Base class for SIMD types color and vector |
| `SGColor: SGSIMD` | A vector of color values, with either 3 or 4 elements |
| `SGVector: SGSIMD` | A vector of values, with either 2, 3, or 4 elements |
| `SGTexture1D: SGValue` | A 1D texture that can be sampled |
| `SGTexture2D: SGValue` | A 2D texture that can be sampled |
| `SGTexture3D: SGValue` | A 3D texture that can be sampled |

Each of these Swift types has an underlying graph data type available as `dataType`.

For more details see [Values.swift](Sources/ShaderGraphCoder/Values.swift).


## Operations

The following operators are supported:

| Operator | Description |
| -------- | ----------- |
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
| `abs` | Absolute value |
| `clamp` | Clamp a value to a range |
| `color3f` | Create an RGB color from computed elements |
| `color4f` | Create an RGBA color from computed elements |
| `cos` | Cosine of an angle in radians |
| `ifGreaterOrEqual` | Conditional operator |
| `ifLess` | Conditional operator |
| `mix` | Linear interpolation |
| `length` | Length (magnitude) of a vector or color |
| `pow` | Power |
| `sin` | Sine of an angle in radians |
| `vector2f` | Create a 2D vector from computed elements |
| `vector3f` | Create a 3D vector from computed elements |
| `vector4f` | Create a 4D vector from computed elements |

Most operators work on `SGScalar`, `SGVector`, and `SGColor` types.

The `ifGreaterOrEqual` and `ifLess` operators are conditional operators that take a condition, a value if true, and a value if false. The `mix` operator is a linear interpolation operator that takes two values and a weight. Since runtime conditionals are not supported in RealityKit, the `ifGreaterOrEqual` and `ifLess` operators are the best way to implement runtime logic.

For more details see [Operations.swift](Sources/ShaderGraphCoder/Operations.swift).


## Sources

The following sources are supported:

| Source | Description |
| ------ | ----------- |
| `SGValue.color3f` | A constant RGB color with a color space |
| `SGValue.color3fParameter` | An RGB color parameter that can be set by later mutating the material |
| `SGValue.color4f` | A constant RGBA color with a color space |
| `SGValue.color4fParameter` | An RGBA color parameter that can be set by later mutating the material |
| `SVValue.float` | A constant floating point number |
| `SGValue.floatParameter` | A parameter that can be set by later mutating the material |
| `SGValue.texture1DParameter` | A 1D texture parameter that can be set by later mutating the material |
| `SGValue.texture2DParameter` | A 2D texture parameter that can be set by later mutating the material |
| `SGValue.texture3DParameter` | A 3D texture parameter that can be set by later mutating the material |
| `SGValue.time` | The time in seconds |
| `SGValue.vector2f` | A constant 2D vector |
| `SGValue.vector2fParameter` | A 2D vector parameter that can be set by later mutating the material |
| `SGValue.vector3f` | A constant 3D vector |
| `SGValue.vector3fParameter` | A 3D vector parameter that can be set by later mutating the material |
| `SGValue.vector4f` | A constant 4D vector |
| `SGValue.vector4fParameter` | A 4D vector parameter that can be set by later mutating the material |
| `SGValue.worldCameraPosition` | The world position of the camera |
| `SGValue.worldNormal` | The world normal of the vertex or fragment being processed |
| `SGValue.worldPosition` | The world position of the vertex or fragment being processed |

For more details see [Sources.swift](Sources/ShaderGraphCoder/Sources.swift).


## Building on the Command Line

### visionOS

```bash
xcodebuild -scheme ShaderGraphCoder -destination 'platform=visionOS Simulator,OS=1.0,name=Apple Vision Pro'
```
