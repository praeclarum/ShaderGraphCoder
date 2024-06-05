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
| `SGMatrix: SGNumeric` | A square matrix with either 2, 3, or 4 dimensions |
| `SGTexture1D: SGValue` | A 1D texture that can be sampled |
| `SGTexture2D: SGValue` | A 2D texture that can be sampled |
| `SGTexture3D: SGValue` | A 3D texture that can be sampled |

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
| `color3f` | Create an RGB color from computed elements |
| `color4f` | Create an RGBA color from computed elements |
| `vector2f` | Create a 2D vector from computed elements |
| `vector3f` | Create a 3D vector from computed elements |
| `vector4f` | Create a 4D vector from computed elements |
| `vector2h` | Create a 2D vector from computed elements |
| `vector3h` | Create a 3D vector from computed elements |
| `vector4h` | Create a 4D vector from computed elements |
| `abs(in)` | Abs |
| `acos(in)` | Acos |
| `add(in1, in2)` | Add |
| `ambientocclusion(coneangle, maxdistance)` | Ambient Occlusion |
| `asin(in)` | Asin |
| `atan2(iny, inx)` | Atan2 |
| `blur(in, size, filtertype)` | Blur |
| `burn(fg, bg, mix)` | Burn |
| `ceil(in)` | Ceiling |
| `cellNoise2D(texcoord)` | Cellular Noise 2D |
| `cellNoise3D(position)` | Cellular Noise 3D |
| `clamp(in, low, high)` | Clamp |
| `contrast(in, amount, pivot)` | Contrast |
| `cos(in)` | Cos |
| `cross(in1, in2)` | Cross Product |
| `determinant(in)` | Determinant |
| `difference(fg, bg, mix)` | Difference |
| `disjointover(fg, bg, mix)` | Disjoint Over |
| `divide(in1, in2)` | Divide |
| `dodge(fg, bg, mix)` | Dodge |
| `dot(in1, in2)` | Dot Product |
| `exp(in)` | Exp |
| `extract(in, index)` | Extract |
| `floor(in)` | Floor |
| `fract(in)` | Fractional |
| `fractal3D(amplitude, octaves, lacunarity, diminish, position)` | Fractal Noise 3D |
| `geometrySwitchCameraindex(mono, left, right)` | Camera Index Switch |
| `geompropvalue(geomprop, default)` | Geometric Property |
| `heightToNormal(in, scale)` | Height To Normal |
| `hsvAdjust(in, amount)` | HSV Adjust |
| `hsvToRGB(in)` | HSV to RGB |
| `ifEqual(value1, value2, in1, in2)` | If Equal |
| `ifGreater(value1, value2, in1, in2)` | If Greater |
| `ifGreaterOrEqual(value1, value2, in1, in2)` | If Greater Or Equal |
| `image(file, default, texcoord, uaddressmode, vaddressmode, filtertype)` | Image |
| `inside(in, mask)` | Inside |
| `invertMatrix(in)` | Invert Matrix |
| `length(in)` | Magnitude |
| `log(in)` | Natural Log |
| `logicalAnd(in1, in2)` | And |
| `logicalNot(in)` | Not |
| `logicalOr(in1, in2)` | Or |
| `logicalXor(in1, in2)` | XOR |
| `luminance(in, lumacoeffs)` | Luminance |
| `mask(fg, bg, mix)` | Mask |
| `matte(fg, bg, mix)` | Matte |
| `max(in1, in2)` | Max |
| `min(in1, in2)` | Min |
| `minus(fg, bg, mix)` | Subtractive Mix |
| `mix(fg, bg, mix)` | Mix |
| `mixColor(fg, bg, mix)` | In |
| `modulo(in1, in2)` | Modulo |
| `multiply(in1, in2)` | Multiply |
| `noise2D(amplitude, pivot, texcoord)` | Noise 2D |
| `noise3D(amplitude, pivot, position)` | Noise 3D |
| `normalMap(in, space, scale, normal, tangent)` | Normal Map |
| `normalMapDecode(in)` | Normal Map Decode |
| `normalize(in)` | Normalize |
| `oneMinus(in)` | One Minus |
| `out(fg, bg, mix)` | Out |
| `outside(in, mask)` | Outside |
| `over(fg, bg, mix)` | Over |
| `overlay(fg, bg, mix)` | Overlay |
| `place2D(texcoord, pivot, scale, rotate, offset)` | Place 2D |
| `plus(fg, bg, mix)` | Additive Mix |
| `pow(in1, in2)` | Power |
| `premult(in)` | Premultiply |
| `ramp4(valuetl, valuetr, valuebl, valuebr, texcoord)` | Ramp 4 Corners |
| `ramplr(valuel, valuer, texcoord)` | Ramp Horizontal |
| `ramptb(valuet, valueb, texcoord)` | Ramp Vertical |
| `range(in, inlow, inhigh, gamma, outlow, outhigh, doclamp)` | Range |
| `reflect(in, normal)` | Reflect |
| `refract(in, normal, eta)` | Refract |
| `remap(in, inlow, inhigh, outlow, outhigh)` | Remap |
| `rgbToHSV(in)` | RGB to HSV |
| `rotate2D(in, amount)` | Rotate 2D |
| `rotate3D(in, amount, axis)` | Rotate 3D |
| `round(in)` | Round |
| `safePow(in1, in2)` | Safe Power |
| `saturate(in, amount, lumacoeffs)` | Saturate |
| `screen(fg, bg, mix)` | Screen |
| `sign(in)` | Sign |
| `sin(in)` | Sin |
| `smoothStep(in, low, high)` | Smooth Step |
| `splitlr(valuel, valuer, center, texcoord)` | Split Horizontal |
| `splittb(valuet, valueb, center, texcoord)` | Split Vertical |
| `sqrt(in)` | Square Root |
| `step(in, edge)` | Step |
| `subtract(in1, in2)` | Subtract |
| `switchValue(in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, which)` | Switch |
| `tan(in)` | Tan |
| `tiledImage(file, default, texcoord, uvtiling, uvoffset, realworldimagesize, realworldtilesize, filtertype)` | Tiled Image |
| `transformMatrix(in, mat)` | Transform Matrix |
| `transformNormal(in, fromspace, tospace)` | Transform Normal |
| `transformPoint(in, fromspace, tospace)` | Transform Point |
| `transformVector(in, fromspace, tospace)` | Transform Vector |
| `transpose(in)` | Transpose |
| `triplanarProjection(filex, filey, filez, default, position, normal, filtertype)` | Triplanar Projection |
| `unpremult(in)` | Unpremultiply |
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
| `SGValue.surfaceAmbientOcclusion` | Surface Ambient Occlusion |
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
