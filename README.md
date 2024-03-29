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

// Create a texture mapped material for visionOS
func textureMap() async throws -> ShaderGraphMaterial {
    // Create the material
    let texture = SGValue.texture2DParameter(name: "ColorTexture")
    let color = texture.sample(texcoord: SGValue.uv0)
    var mat = try await ShaderGraphMaterial(surface: SGPBRSurface(baseColor: color), geometryModifier: nil)
    
    // Load the texture as a TextureResource
    guard let textureURL = Bundle.module.url(forResource: "TestTexture", withExtension: "png") else {
        throw URLError(.fileDoesNotExist)
    }
    let textureResource = try TextureResource.load(contentsOf: textureURL)
    
    // Bind the texure to the material's texture parameter
    try mat.setParameter(name: "ColorTexture", value: .textureResource(textureResource))
    
    return mat
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
| `%` | Modulo |
| `abs` | Absolute value |
| `ceil` | Ceiling |
| `clamp` | Clamp a value to a range |
| `color3f` | Create an RGB color from computed elements |
| `color4f` | Create an RGBA color from computed elements |
| `cos` | Cosine of an angle in radians |
| `cross` | Cross product |
| `dot` | Dot product |
| `floor` | Floor |
| `fract` | Fractional part |
| `ifGreaterOrEqual` | Conditional operator |
| `ifLess` | Conditional operator |
| `length` | Length (magnitude) of a vector or color |
| `map` | Linearly map a value from one range to another |
| `max` | Maximum of two values |
| `min` | Minimum of two values |
| `mix` | Linear interpolation |
| `normalize` | Normalize a vector |
| `oneMinus` | One minus a value |
| `pow` | Power |
| `round` | Round |
| `safePow` | Safe power |
| `sign` | Sign of a value |
| `sin` | Sine of an angle in radians |
| `sqrt` | Square root |
| `tan` | Tangent of an angle in radians |
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
| `SGValue.customAttribute` | A value passed from the geometry modifier to the surface shader |
| `SVValue.float` | A constant floating point number |
| `SGValue.floatParameter` | A parameter that can be set by later mutating the material |
| `SGValue.modelNormal` | The model normal of the vertex or fragment being processed |
| `SGValue.modelPosition` | The model position of the vertex or fragment being processed |
| `SGValue.objectNormal` | The object normal of the vertex or fragment being processed |
| `SGValue.objectPosition` | The object position of the vertex or fragment being processed |
| `SGValue.texture1DParameter` | A 1D texture parameter that can be set by later mutating the material |
| `SGValue.texture2DParameter` | A 2D texture parameter that can be set by later mutating the material |
| `SGValue.texture3DParameter` | A 3D texture parameter that can be set by later mutating the material |
| `SGValue.time` | The time in seconds |
| `SGValue.uv(index)` | UV coordinate of the vertex or pixel |
| `SGValue.uv0` | The first UV coordinate of the vertex or pixel |
| `SGValue.uv1` | The second UV coordinate of the vertex or pixel |
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
