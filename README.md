# ShaderGraphCoder

Write RealityKit shaders in Swift.


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
    let color: SGColor = .color3f([0, 0, 1]) * sin(SGValue.time * frequency)
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
| `SGValue` | The parent value type containing static methods and properties to get global values |
| `SGScalar: SGValue` | A single value, usually a floating point number |
| `SGVector: SGSIMD` | A vector of values, with either 2, 3, or 4 elements |
| `SGColor: SGSIMD` | A vector of color values, with either 3 or 4 elements |
| `SGTexture1D` | A 1D texture that can be sampled |
| `SGTexture2D` | A 2D texture that can be sampled |
| `SGTexture3D` | A 3D texture that can be sampled |

Each of these Swift types has an underlying graph data type available as `dataType`.


## Operations

The following operators are supported:

| Operator | Description |
| -------- | ----------- |
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
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


## Building on the Command Line

### visionOS

```bash
xcodebuild -scheme ShaderGraphCoder -destination 'platform=visionOS Simulator,OS=1.0,name=Apple Vision Pro'
```
