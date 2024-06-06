# ShaderGraphCoder

An embedded DSL to write RealityKit shaders in Swift.

**Supported Platforms:** visionOS


## Examples

```swift
// Create a solid red material for visionOS
func solidRed() async throws -> ShaderGraphMaterial {
    let color: SGColor = .color3f([1, 0, 0])
    let surface = pbrSurface(baseColor: color)
    return try await ShaderGraphMaterial(surface: surface)
}

// Create a pulsing blue material for visionOS
func pulsingBlue() async throws -> ShaderGraphMaterial {
    let frequency = SGValue.floatParameter(name: "Frequency", defaultValue: 2)
    let color: SGColor = .color3f([0, 0, 1]) * sin(SGValue.time * frequency * (2*Float.pi))
    let surface = pbrSurface(baseColor: color)
    return try await ShaderGraphMaterial(surface: surface)
}

// Create a texture mapped material for visionOS
func textureMap(textureLocalURL: URL) async throws -> ShaderGraphMaterial {
    // Create the surface by sampling the texture map
    let surface =
        SGValue
        .texture(contentsOf: textureLocalURL)
        .sampleColor3f(texcoord: SGValue.uv0)
        .pbrSurface()
    return try await ShaderGraphMaterial(surface: surface)
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
| `SGMatrix: SGNumeric` | A square matrix with either 2, 3, or 4 dimensions |
| `SGTexture: SGValue` | A 2D texture that can be sampled or read |
| `SGToken: SGValue` | A surface shader or geometry modifier |

Each of these Swift types has an underlying graph data type available as `dataType`.

For more details see [Values.swift](Sources/ShaderGraphCoder/Values.swift).


## Operations

There are over 100 operators that combine
`SGScalar`, `SGVector`, `SGColor`, and `SGMatrix` values
in varied and wonderful ways. From simple arithmetic to complex
blends, a bit of everything is available.

The `ifGreaterOrEqual` and `ifLess` operators are conditional operators that take a condition, a value if true, and a value if false. The `mix` operator is a linear interpolation operator that takes two values and a weight. Since runtime conditionals are not supported in RealityKit, the `ifGreaterOrEqual` and `ifLess` operators are the best way to implement runtime logic.

The following operators are supported:

| Operator | Description |
| -------- | ----------- |
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
| `%` | Modulo |
| `&&` | Logical And |
| `\|\|` | Logical Or |
| `^^` | Logical Xor |
| `abs(in1)` | Abs |
| `acos(in1)` | Acos |
| `add(in1, in2)` | Add |
| `ambientOcclusion(coneangle, maxdistance)` | Ambient Occlusion |
| `asin(in1)` | Asin |
| `atan2(iny, inx)` | Atan2 |
| `blur(in1, size, ...)` | Blur |
| `burn(fg, bg, ...)` | Burn |
| `ceil(in1)` | Ceiling |
| `cellNoise2D(texcoord)` | Cellular Noise 2D |
| `cellNoise3D(position)` | Cellular Noise 3D |
| `clamp(in1, min, ...)` | Clamp |
| `contrast(in1, amount, ...)` | Contrast |
| `cos(in1)` | Cos |
| `cross(in1, in2)` | Cross Product |
| `determinant(in1)` | Determinant |
| `difference(fg, bg, ...)` | Difference |
| `disjointover(fg, bg, ...)` | Disjoint Over |
| `divide(in1, in2)` | Divide |
| `dodge(fg, bg, ...)` | Dodge |
| `dot(in1, in2)` | Dot Product |
| `exp(in1)` | Exp |
| `extract(in1, index)` | Extract |
| `floor(in1)` | Floor |
| `fract(in1)` | Fractional |
| `fractal3D(amplitude, octaves, ...)` | Fractal Noise 3D |
| `geometryModifier(modelPositionOffset, color, ...)` | Geometry Modifier |
| `geometrySwitchCameraIndex(mono, left, ...)` | Camera Index Switch |
| `heightToNormal(in1, scale)` | Height To Normal |
| `hsvAdjust(in1, amount)` | HSV Adjust |
| `hsvToRGB(in1)` | HSV to RGB |
| `ifEqual(value1, value2, ...)` | If Equal |
| `ifGreater(value1, value2, ...)` | If Greater |
| `ifGreaterOrEqual(value1, value2, ...)` | If Greater Or Equal |
| `image(file, defaultValue, ...)` | Image |
| `inside(in1, mask)` | Inside |
| `invertMatrix(in1)` | Invert Matrix |
| `length(in1)` | Magnitude |
| `log(in1)` | Natural Log |
| `logicalAnd(in1, in2)` | And |
| `logicalNot(in1)` | Not |
| `logicalOr(in1, in2)` | Or |
| `logicalXor(in1, in2)` | XOR |
| `luminance(in1, lumacoeffs)` | Luminance |
| `mask(fg, bg, ...)` | Mask |
| `matte(fg, bg, ...)` | Matte |
| `max(in1, in2)` | Max |
| `min(in1, in2)` | Min |
| `minus(fg, bg, ...)` | Subtractive Mix |
| `mix(fg, bg, ...)` | Mix |
| `mixColor(fg, bg, ...)` | In |
| `modulo(in1, in2)` | Modulo |
| `multiply(in1, in2)` | Multiply |
| `noise2D(amplitude, pivot, ...)` | Noise 2D |
| `noise3D(amplitude, pivot, ...)` | Noise 3D |
| `normalMap(in1, space, ...)` | Normal Map |
| `normalMapDecode(in1)` | Normal Map Decode |
| `normalize(in1)` | Normalize |
| `oneMinus(in1)` | One Minus |
| `out(fg, bg, ...)` | Out |
| `outside(in1, mask)` | Outside |
| `over(fg, bg, ...)` | Over |
| `overlay(fg, bg, ...)` | Overlay |
| `pbrSurface(baseColor, emissiveColor, ...)` | PBR Surface |
| `pixel(file, uWrapMode, ...)` | Image 2D Pixel |
| `pixelGradient(file, uWrapMode, ...)` | Image 2D Gradient Pixel |
| `pixelLOD(file, uWrapMode, ...)` | Image 2D LOD Pixel |
| `place2D(texcoord, pivot, ...)` | Place 2D |
| `plus(fg, bg, ...)` | Additive Mix |
| `pow(in1, in2)` | Power |
| `premult(in1)` | Premultiply |
| `ramp4(valuetl, valuetr, ...)` | Ramp 4 Corners |
| `ramplr(valuel, valuer, ...)` | Ramp Horizontal |
| `ramptb(valuet, valueb, ...)` | Ramp Vertical |
| `range(in1, inlow, ...)` | Range |
| `read(file, defaultValue, ...)` | Image 2D Read |
| `reflect(in1, normal)` | Reflect |
| `refract(in1, normal, ...)` | Refract |
| `remap(in1, inlow, ...)` | Remap |
| `rgbToHSV(in1)` | RGB to HSV |
| `rotate2D(in1, amount)` | Rotate 2D |
| `rotate3D(in1, amount, ...)` | Rotate 3D |
| `round(in1)` | Round |
| `safePow(in1, in2)` | Safe Power |
| `sample(file, uWrapMode, ...)` | Image 2D |
| `sampleCube(file, uWrapMode, ...)` | Cube Image |
| `sampleCubeGradient(file, uWrapMode, ...)` | Cube Image Gradient |
| `sampleCubeLOD(file, uWrapMode, ...)` | Cube Image LOD |
| `sampleGradient(file, uWrapMode, ...)` | Image 2D Gradient |
| `sampleLOD(file, uWrapMode, ...)` | Image 2D LOD |
| `saturate(in1, amount, ...)` | Saturate |
| `screen(fg, bg, ...)` | Screen |
| `sign(in1)` | Sign |
| `sin(in1)` | Sin |
| `smoothStep(in1, low, ...)` | Smooth Step |
| `splitlr(valuel, valuer, ...)` | Split Horizontal |
| `splittb(valuet, valueb, ...)` | Split Vertical |
| `sqrt(in1)` | Square Root |
| `step(in1, edge)` | Step |
| `subtract(in1, in2)` | Subtract |
| `switchValue(in1, in2, ...)` | Switch |
| `tan(in1)` | Tan |
| `tiledImage(file, defaultValue, ...)` | Tiled Image |
| `transformMatrix(in1, mat)` | Transform Matrix |
| `transformNormal(in1, fromspace, ...)` | Transform Normal |
| `transformPoint(in1, fromspace, ...)` | Transform Point |
| `transformVector(in1, fromspace, ...)` | Transform Vector |
| `transpose(in1)` | Transpose |
| `triplanarProjection(filex, filey, ...)` | Triplanar Projection |
| `unlitSurface(color, opacity, ...)` | Unlit Surface |
| `unpremult(in1)` | Unpremultiply |
| `worleyNoise2DFloat(texcoord, jitter)` | Worley Noise 2D |
| `worleyNoise2DVector2(texcoord, jitter)` | Worley Noise 2D |
| `worleyNoise2DVector3(texcoord, jitter)` | Worley Noise 2D |
| `worleyNoise3DFloat(position, jitter)` | Worley Noise 3D |
| `worleyNoise3DVector2(position, jitter)` | Worley Noise 3D |
| `worleyNoise3DVector3(position, jitter)` | Worley Noise 3D |


For more details see [Operations.swift](Sources/ShaderGraphCoder/Operations.swift) and [Operations.g.swift](Sources/ShaderGraphCoder/Operations.g.swift).


## Sources

The following sources are supported:

| Source | Description |
| ------ | ----------- |
| `SGValue.color3f` | A constant RGB color with an optional color space |
| `SGValue.color3fParameter` | An RGB color parameter that can be set by later mutating the material |
| `SGValue.color4f` | A constant RGBA color with an optional color space |
| `SGValue.color4fParameter` | An RGBA color parameter that can be set by later mutating the material |
| `SGValue.surfaceCustomAttribute` | A value passed from the geometry modifier to the surface shader |
| `SVValue.float` | A constant floating point number |
| `SGValue.floatParameter` | A parameter that can be set by later mutating the material |
| `SGValue.modelNormal` | The model normal of the vertex or fragment being processed |
| `SGValue.modelPosition` | The model position of the vertex or fragment being processed |
| `SGValue.objectNormal` | The object normal of the vertex or fragment being processed |
| `SGValue.objectPosition` | The object position of the vertex or fragment being processed |
| `SGValue.textureParameter` | A 2D texture parameter that can be set by later mutating the material |
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
| `SGValue.bitangent(space, index)` | Bitangent |
| `SGValue.cameraPosition(space)` | Camera Position |
| `SGValue.frame` | Frame |
| `SGValue.geomcolorColor3(index)` | Geometry Color |
| `SGValue.geomcolorColor4(index)` | Geometry Color |
| `SGValue.geomcolorFloat(index)` | Geometry Color |
| `SGValue.geometryModifierCustomAttribute` | Geometry Modifier Custom Attribute |
| `SGValue.geometryModifierCustomAttributeHalf20` | Geometry Modifier Custom Attribute 0 |
| `SGValue.geometryModifierCustomAttributeHalf21` | Geometry Modifier Custom Attribute 1 |
| `SGValue.geometryModifierCustomAttributeHalf40` | Geometry Modifier Custom Attribute 0 |
| `SGValue.geometryModifierCustomAttributeHalf41` | Geometry Modifier Custom Attribute 1 |
| `SGValue.geometryModifierCustomAttributeHalf42` | Geometry Modifier Custom Attribute 2 |
| `SGValue.geometryModifierCustomAttributeHalf43` | Geometry Modifier Custom Attribute 3 |
| `SGValue.geometryModifierCustomParameter` | Geometry Modifier Custom Parameter |
| `SGValue.geometryModifierModelPositionOffset` | Geometry Modifier Model Position Offset |
| `SGValue.geometryModifierModelToView` | Geometry Modifier Model To View |
| `SGValue.geometryModifierModelToWorld` | Geometry Modifier Model To World |
| `SGValue.geometryModifierNormalToWorld` | Geometry Modifier Normal To World |
| `SGValue.geometryModifierProjectionToView` | Geometry Modifier Projection To View |
| `SGValue.geometryModifierUV0Offset` | Geometry Modifier uv0 Offset |
| `SGValue.geometryModifierUV0Transform` | Geometry Modifier uv0 Transform |
| `SGValue.geometryModifierUV1Offset` | Geometry Modifier uv1 Offset |
| `SGValue.geometryModifierUV1Transform` | Geometry Modifier uv1 Transform |
| `SGValue.geometryModifierVertexId` | Geometry Modifier Vertex ID |
| `SGValue.geometryModifierViewToProjection` | Geometry Modifier View To Projection |
| `SGValue.geometryModifierWorldToModel` | Geometry Modifier World To Model |
| `SGValue.materialParametersBaseColorTint` | Material Parameter Base Color Tint |
| `SGValue.materialParametersClearcoatRoughnessScale` | Material Parameter Roughness Scale |
| `SGValue.materialParametersClearcoatScale` | Material Parameter Clearcoat Scale |
| `SGValue.materialParametersEmissiveColor` | Material Parameter Emissive Color |
| `SGValue.materialParametersMetallicScale` | Material Parameter Metallic Scale |
| `SGValue.materialParametersOpacityScale` | Material Parameter Opacity Scale |
| `SGValue.materialParametersOpacityThreshold` | Material Parameter Opacity Threshold |
| `SGValue.materialParametersRoughnessScale` | Material Parameter Roughness Scale |
| `SGValue.materialParametersSpecularScale` | Material Parameter Specular Scale |
| `SGValue.normal(space)` | Normal |
| `SGValue.position(space)` | Position |
| `SGValue.surfaceBaseColor` | Surface Base Color |
| `SGValue.surfaceClearcoat` | Surface Clearcoat |
| `SGValue.surfaceClearcoatRoughness` | Surface Clearcoat Roughness |
| `SGValue.surfaceCustomAttribute` | Surface Custom Attribute |
| `SGValue.surfaceCustomAttributeHalf20` | Surface Custom Attribute 0 |
| `SGValue.surfaceCustomAttributeHalf21` | Surface Custom Attribute 1 |
| `SGValue.surfaceCustomAttributeHalf40` | Surface Custom Attribute 0 |
| `SGValue.surfaceCustomAttributeHalf41` | Surface Custom Attribute 1 |
| `SGValue.surfaceCustomAttributeHalf42` | Surface Custom Attribute 2 |
| `SGValue.surfaceCustomAttributeHalf43` | Surface Custom Attribute 3 |
| `SGValue.surfaceCustomParameter` | Surface Custom Parameter |
| `SGValue.surfaceEmissiveColor` | Surface Emissive Color |
| `SGValue.surfaceMetallic` | Surface Metallic |
| `SGValue.surfaceModelToView` | Surface Model To View |
| `SGValue.surfaceModelToWorld` | Surface Model To World |
| `SGValue.surfaceOpacity` | Surface Opacity |
| `SGValue.surfaceProjectionToView` | Surface Projection To View |
| `SGValue.surfaceRoughness` | Surface Roughness |
| `SGValue.surfaceScreenPosition` | Surface Screen Position |
| `SGValue.surfaceSpecular` | Surface Specular |
| `SGValue.surfaceViewDirection` | Surface View Direction |
| `SGValue.surfaceViewToProjection` | Surface View To Projection |
| `SGValue.surfaceWorldToView` | Surface World To View |
| `SGValue.tangent(space, index)` | Tangent |
| `SGValue.texcoordVector2(index)` | Texture Coordinates |
| `SGValue.texcoordVector3(index)` | Texture Coordinates |
| `SGValue.time` | Time |
| `SGValue.upDirection(space)` | Up Direction |
| `SGValue.viewDirection(space)` | View Direction |


For more details see [Sources.swift](Sources/ShaderGraphCoder/Sources.swift) and [Sources.g.swift](Sources/ShaderGraphCoder/Sources.g.swift).


## Building on the Command Line

### visionOS

```bash
xcodebuild -scheme ShaderGraphCoder -destination 'platform=visionOS Simulator,OS=1.0,name=Apple Vision Pro'
```
