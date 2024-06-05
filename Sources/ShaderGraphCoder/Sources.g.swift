// Autogenerated by opgen.py
import Foundation
import simd
public extension SGValue {
    static func bitangent(space: SGSpace = SGSpace.object, index: Int = 0) -> SGVector {
        let inputs: [SGNode.Input] = [
            .init(name: "space", connection: SGString(source: .constant(.string(space.rawValue)))),
            .init(name: "index", connection: SGScalar(source: .constant(.int(index)))),
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_bitangent_vector3",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector3f)])))
    }
    /// Camera Position
    static func cameraPosition(space: SGSpace = SGSpace.world) -> SGVector {
        let inputs: [SGNode.Input] = [
            .init(name: "space", connection: SGString(source: .constant(.string(space.rawValue)))),
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_cameraposition_vector3",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector3f)])))
    }
    /// Frame
    static var frame: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_frame_float",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Geometry Color
    static func geomcolorColor3(index: Int = 0) -> SGColor {
        let inputs: [SGNode.Input] = [
            .init(name: "index", connection: SGScalar(source: .constant(.int(index)))),
        ]
        return SGColor(source: .nodeOutput(SGNode(
            nodeType: "ND_geomcolor_color3",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.color3f)])))
    }
    /// Geometry Color
    static func geomcolorColor4(index: Int = 0) -> SGColor {
        let inputs: [SGNode.Input] = [
            .init(name: "index", connection: SGScalar(source: .constant(.int(index)))),
        ]
        return SGColor(source: .nodeOutput(SGNode(
            nodeType: "ND_geomcolor_color4",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.color4f)])))
    }
    /// Geometry Color
    static func geomcolorFloat(index: Int = 0) -> SGScalar {
        let inputs: [SGNode.Input] = [
            .init(name: "index", connection: SGScalar(source: .constant(.int(index)))),
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_geomcolor_float",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Geometry Modifier Custom Attribute
    static var geometryModifierCustomAttribute: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_custom_attribute",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4f)])))
    }
    /// Geometry Modifier Custom Attribute 0
    static var geometryModifierCustomAttributeHalf20: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_custom_attribute_half2_0",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector2h)])))
    }
    /// Geometry Modifier Custom Attribute 1
    static var geometryModifierCustomAttributeHalf21: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_custom_attribute_half2_1",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector2h)])))
    }
    /// Geometry Modifier Custom Attribute 0
    static var geometryModifierCustomAttributeHalf40: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_custom_attribute_half4_0",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4h)])))
    }
    /// Geometry Modifier Custom Attribute 1
    static var geometryModifierCustomAttributeHalf41: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_custom_attribute_half4_1",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4h)])))
    }
    /// Geometry Modifier Custom Attribute 2
    static var geometryModifierCustomAttributeHalf42: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_custom_attribute_half4_2",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4h)])))
    }
    /// Geometry Modifier Custom Attribute 3
    static var geometryModifierCustomAttributeHalf43: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_custom_attribute_half4_3",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4h)])))
    }
    /// Geometry Modifier Custom Parameter
    static var geometryModifierCustomParameter: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_custom_parameter",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4f)])))
    }
    /// Geometry Modifier Model Position Offset
    static var geometryModifierModelPositionOffset: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_model_position_offset",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector3f)])))
    }
    /// Geometry Modifier Model To View
    static var geometryModifierModelToView: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_model_to_view",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix4d)])))
    }
    /// Geometry Modifier Model To World
    static var geometryModifierModelToWorld: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_model_to_world",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix4d)])))
    }
    /// Geometry Modifier Normal To World
    static var geometryModifierNormalToWorld: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_normal_to_world",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix3d)])))
    }
    /// Geometry Modifier Projection To View
    static var geometryModifierProjectionToView: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_projection_to_view",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix4d)])))
    }
    /// Geometry Modifier uv0 Offset
    static var geometryModifierUV0Offset: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_uv0_offset",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector2f)])))
    }
    /// Geometry Modifier uv0 Transform
    static var geometryModifierUV0Transform: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_uv0_transform",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix2d)])))
    }
    /// Geometry Modifier uv1 Offset
    static var geometryModifierUV1Offset: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_uv1_offset",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector2f)])))
    }
    /// Geometry Modifier uv1 Transform
    static var geometryModifierUV1Transform: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_uv1_transform",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix2d)])))
    }
    /// Geometry Modifier Vertex ID
    static var geometryModifierVertexId: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_vertex_id",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.int)])))
    }
    /// Geometry Modifier View To Projection
    static var geometryModifierViewToProjection: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_view_to_projection",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix4d)])))
    }
    /// Geometry Modifier World To Model
    static var geometryModifierWorldToModel: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_geometry_modifier_world_to_model",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix4d)])))
    }
    /// Material Parameter Base Color Tint
    static var materialParametersBaseColorTint: SGColor {
        let inputs: [SGNode.Input] = [
        ]
        return SGColor(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_material_parameters_base_color_tint",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.color3f)])))
    }
    /// Material Parameter Roughness Scale
    static var materialParametersClearcoatRoughnessScale: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_material_parameters_clearcoat_roughness_scale",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Material Parameter Clearcoat Scale
    static var materialParametersClearcoatScale: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_material_parameters_clearcoat_scale",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Material Parameter Emissive Color
    static var materialParametersEmissiveColor: SGColor {
        let inputs: [SGNode.Input] = [
        ]
        return SGColor(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_material_parameters_emissive_color",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.color3f)])))
    }
    /// Material Parameter Metallic Scale
    static var materialParametersMetallicScale: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_material_parameters_metallic_scale",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Material Parameter Opacity Scale
    static var materialParametersOpacityScale: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_material_parameters_opacity_scale",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Material Parameter Opacity Threshold
    static var materialParametersOpacityThreshold: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_material_parameters_opacity_threshold",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Material Parameter Roughness Scale
    static var materialParametersRoughnessScale: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_material_parameters_roughness_scale",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Material Parameter Specular Scale
    static var materialParametersSpecularScale: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_material_parameters_specular_scale",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    static func normal(space: SGSpace = SGSpace.object) -> SGVector {
        let inputs: [SGNode.Input] = [
            .init(name: "space", connection: SGString(source: .constant(.string(space.rawValue)))),
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_normal_vector3",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector3f)])))
    }
    static func position(space: SGSpace = SGSpace.object) -> SGVector {
        let inputs: [SGNode.Input] = [
            .init(name: "space", connection: SGString(source: .constant(.string(space.rawValue)))),
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_position_vector3",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector3f)])))
    }
    /// Surface Ambient Occlusion
    static var surfaceAmbientOcclusion: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_ambient_occlusion",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Surface Base Color
    static var surfaceBaseColor: SGColor {
        let inputs: [SGNode.Input] = [
        ]
        return SGColor(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_base_color",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.color3f)])))
    }
    /// Surface Clearcoat
    static var surfaceClearcoat: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_clearcoat",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Surface Clearcoat Roughness
    static var surfaceClearcoatRoughness: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_clearcoat_roughness",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Surface Custom Attribute
    static var surfaceCustomAttribute: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_custom_attribute",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4f)])))
    }
    /// Surface Custom Attribute 0
    static var surfaceCustomAttributeHalf20: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_custom_attribute_half2_0",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector2h)])))
    }
    /// Surface Custom Attribute 1
    static var surfaceCustomAttributeHalf21: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_custom_attribute_half2_1",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector2h)])))
    }
    /// Surface Custom Attribute 0
    static var surfaceCustomAttributeHalf40: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_custom_attribute_half4_0",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4h)])))
    }
    /// Surface Custom Attribute 1
    static var surfaceCustomAttributeHalf41: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_custom_attribute_half4_1",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4h)])))
    }
    /// Surface Custom Attribute 2
    static var surfaceCustomAttributeHalf42: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_custom_attribute_half4_2",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4h)])))
    }
    /// Surface Custom Attribute 3
    static var surfaceCustomAttributeHalf43: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_custom_attribute_half4_3",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4h)])))
    }
    /// Surface Custom Parameter
    static var surfaceCustomParameter: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_custom_parameter",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4f)])))
    }
    /// Surface Emissive Color
    static var surfaceEmissiveColor: SGColor {
        let inputs: [SGNode.Input] = [
        ]
        return SGColor(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_emissive_color",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.color3f)])))
    }
    /// Surface Metallic
    static var surfaceMetallic: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_metallic",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Surface Model To View
    static var surfaceModelToView: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_model_to_view",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix4d)])))
    }
    /// Surface Model To World
    static var surfaceModelToWorld: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_model_to_world",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix4d)])))
    }
    /// Surface Opacity
    static var surfaceOpacity: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_opacity",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Surface Projection To View
    static var surfaceProjectionToView: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_projection_to_view",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix4d)])))
    }
    /// Surface Roughness
    static var surfaceRoughness: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_roughness",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Surface Screen Position
    static var surfaceScreenPosition: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_screen_position",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector4f)])))
    }
    /// Surface Specular
    static var surfaceSpecular: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_specular",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    /// Surface View Direction
    static var surfaceViewDirection: SGVector {
        let inputs: [SGNode.Input] = [
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_view_direction",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector3f)])))
    }
    /// Surface View To Projection
    static var surfaceViewToProjection: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_view_to_projection",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix4d)])))
    }
    /// Surface World To View
    static var surfaceWorldToView: SGMatrix {
        let inputs: [SGNode.Input] = [
        ]
        return SGMatrix(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_surface_world_to_view",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.matrix4d)])))
    }
    static func tangent(space: SGSpace = SGSpace.object, index: Int = 0) -> SGVector {
        let inputs: [SGNode.Input] = [
            .init(name: "space", connection: SGString(source: .constant(.string(space.rawValue)))),
            .init(name: "index", connection: SGScalar(source: .constant(.int(index)))),
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_tangent_vector3",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector3f)])))
    }
    /// Texture Coordinates
    static func texcoordVector2(index: Int = 0) -> SGVector {
        let inputs: [SGNode.Input] = [
            .init(name: "index", connection: SGScalar(source: .constant(.int(index)))),
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_texcoord_vector2",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector2f)])))
    }
    /// Texture Coordinates
    static func texcoordVector3(index: Int = 0) -> SGVector {
        let inputs: [SGNode.Input] = [
            .init(name: "index", connection: SGScalar(source: .constant(.int(index)))),
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_texcoord_vector3",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector3f)])))
    }
    /// Time
    static var time: SGScalar {
        let inputs: [SGNode.Input] = [
        ]
        return SGScalar(source: .nodeOutput(SGNode(
            nodeType: "ND_time_float",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.float)])))
    }
    static func updirection(space: SGSpace = SGSpace.world) -> SGVector {
        let inputs: [SGNode.Input] = [
            .init(name: "space", connection: SGString(source: .constant(.string(space.rawValue)))),
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_updirection_vector3",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector3f)])))
    }
    /// View Direction
    static func viewdirection(space: SGSpace = SGSpace.world) -> SGVector {
        let inputs: [SGNode.Input] = [
            .init(name: "space", connection: SGString(source: .constant(.string(space.rawValue)))),
        ]
        return SGVector(source: .nodeOutput(SGNode(
            nodeType: "ND_realitykit_viewdirection_vector3",
            inputs: inputs,
            outputs: [.init(dataType: SGDataType.vector3f)])))
    }
}
