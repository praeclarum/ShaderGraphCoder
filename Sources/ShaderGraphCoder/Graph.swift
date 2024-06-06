//
//  Graph.swift
//  ShaderGraphCoder
//
//  Created by Frank A. Krueger on 2/10/24.
//

import Foundation
import simd

public class SGNode: Identifiable, Equatable, Hashable {
    private static var nextId: Int = 1
    public let id: Int
    public let nodeType: String
    public let inputs: [Input]
    public let outputs: [Output]
    
    public var dataType: SGDataType { outputs[0].dataType }
    public var outputName: String { outputs[0].name }
    
    public struct Input {
        public let name: String
        public let dataType: SGDataType
        public let value: SGValue?
        public init(name: String, dataType: SGDataType, connection: SGValue?) {
            self.name = name
            self.dataType = dataType
            self.value = connection
        }
        public init(name: String, connection: SGValue) {
            self.name = name
            self.dataType = connection.dataType
            self.value = connection
        }
        public init(name: String, dataType: SGDataType) {
            self.name = name
            self.dataType = dataType
            self.value = nil
        }
    }
    
    public struct Output {
        public let name: String
        public let dataType: SGDataType
        public init(name: String, dataType: SGDataType) {
            self.name = name
            self.dataType = dataType
        }
        public init(dataType: SGDataType) {
            self.name = "out"
            self.dataType = dataType
        }
    }
    
    public init(nodeType: String, inputs: [Input], outputs: [Output]) {
        self.id = SGNode.nextId
        SGNode.nextId += 1
        self.nodeType = nodeType
        self.inputs = inputs
        self.outputs = outputs
    }
    public static func == (lhs: SGNode, rhs: SGNode) -> Bool {
        lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine("n")
        hasher.combine(id)
    }

    public func getOutputValue(name: String) -> SGValueSource { .nodeOutput(self, name) }

    public func findOutput(name: String) -> Output? {
        outputs.first { $0.name == name }
    }
}

public enum SGValueSource {
    case nodeOutput(_ node: SGNode, _ outputName: String)
    case constant(_ value: SGConstantValue)
    case parameter(name: String, defaultValue: SGConstantValue)
    case error(_ error: String, values: [SGValue])
    
    public var dataType: SGDataType {
        switch self {
        case .nodeOutput(let node, let outputName):
            if let o = node.findOutput(name: outputName) {
                return o.dataType
            }
            return .float
        case .constant(let value):
            return value.dataType
        case .parameter(name: _, defaultValue: let defaultValue):
            return defaultValue.dataType
        case .error:
            return .error
        }
    }

    public static func nodeOutput(_ node: SGNode) -> SGValueSource {
        .nodeOutput(node, "out")
    }
}

public enum SGDataType: String {
    case asset = "asset"
    case bool = "bool"
    case color3f = "color3f"
    case color4f = "color4f"
    case error = "error"
    case half = "half"
    case float = "float"
    case geometryModifier = "GeometryModifier"
    case int = "int"
    case string = "string"
    case surface = "Surface"
    case matrix2d = "matrix2d"
    case matrix3d = "matrix3d"
    case matrix4d = "matrix4d"
    case vector2f = "float2"
    case vector3f = "float3"
    case vector4f = "float4"
    case vector2h = "half2"
    case vector3h = "half3"
    case vector4h = "half4"
    case vector2i = "int2"
    case vector3i = "int3"
    case vector4i = "int4"
    
    public var isScalar: Bool {
        switch self {
        case .bool:
            return true
        case .float:
            return true
        case .half:
            return true
        case .int:
            return true
        default:
            return false
        }
    }
    public var isColor: Bool {
        switch self {
        case .color3f:
            return true
        case .color4f:
            return true
        default:
            return false
        }
    }
}

public enum SGConstantValue {
    case bool(_ value: Bool)
    case color3f(_ value: SIMD3<Float>, colorSpace: SGColorSpace?)
    case color4f(_ value: SIMD4<Float>, colorSpace: SGColorSpace?)
    case emptyTexture1D
    case emptyTexture2D
    case emptyTexture3D
    case float(_ value: Float)
    case half(_ value: Float16)
    case int(_ value: Int)
    case string(_ value: String)
    case vector2f(_ value: SIMD2<Float>)
    case vector3f(_ value: SIMD3<Float>)
    case vector4f(_ value: SIMD4<Float>)
    case vector2h(_ value: SIMD2<Float16>)
    case vector3h(_ value: SIMD3<Float16>)
    case vector4h(_ value: SIMD4<Float16>)
    case vector2i(_ value: SIMD2<Int>)
    case vector3i(_ value: SIMD3<Int>)
    case vector4i(_ value: SIMD4<Int>)
    case matrix2d(_ value: simd_float2x2)
    case matrix3d(_ value: simd_float3x3)
    case matrix4d(_ value: simd_float4x4)
    public var dataType: SGDataType {
        switch self {
        case .bool:
            return .bool
        case .color3f:
            return .color3f
        case .color4f:
            return .color4f
        case .emptyTexture1D:
            return .asset
        case .emptyTexture2D:
            return .asset
        case .emptyTexture3D:
            return .asset
        case .float:
            return .float
        case .half:
            return .half
        case .int:
            return .int
        case .matrix2d:
            return .matrix2d
        case .matrix3d:
            return .matrix3d
        case .matrix4d:
            return .matrix4d
        case .string:
            return .string
        case .vector2f:
            return .vector2f
        case .vector3f:
            return .vector3f
        case .vector4f:
            return .vector4f
        case .vector2h:
            return .vector2h
        case .vector3h:
            return .vector3h
        case .vector4h:
            return .vector4h
        case .vector2i:
            return .vector2i
        case .vector3i:
            return .vector3i
        case .vector4i:
            return .vector4i
        }
    }
    public static func color3f(_ value: SIMD3<Float>) -> SGConstantValue {
        return SGConstantValue.color3f(value, colorSpace: nil)
    }
    public static func color4f(_ value: SIMD4<Float>) -> SGConstantValue {
        return SGConstantValue.color4f(value, colorSpace: nil)
    }
}

public enum SGColorSpace: String {
    case linearSRGB = "lin_srgb"
    case textureSRGB = "srgb_texture"
}

public enum ShaderGraphCoderError: Error {
    case failedToEncodeUSDAsData
    case graphContainsErrors(errors: [String])
}

public class SGSurface: SGNode {
}

public class SGPBRSurface: SGSurface {
    public init(baseColor: SGColor? = nil, roughness: SGScalar? = nil, metallic: SGScalar? = nil, emissiveColor: SGColor? = nil, ambientOcclusion: SGScalar? = nil, clearcoat: SGScalar? = nil, clearcoatRoughness: SGScalar? = nil, normal: SGVector? = nil, hasPremultipliedAlpha: SGScalar? = nil, opacity: SGScalar? = nil, opacityThreshold: SGScalar? = nil, specular: SGScalar? = nil) {
        super.init(
            nodeType: "ND_realitykit_pbr_surfaceshader",
            inputs: [
                .init(name: "ambientOcclusion", dataType: .float, connection: ambientOcclusion),
                .init(name: "baseColor", dataType: .color3f, connection: baseColor),
                .init(name: "clearcoat", dataType: .float, connection: clearcoat),
                .init(name: "clearcoatRoughness", dataType: .float, connection: clearcoatRoughness),
                .init(name: "emissiveColor", dataType: .color3f, connection: emissiveColor),
                .init(name: "hasPremultipliedAlpha", dataType: .bool, connection: hasPremultipliedAlpha),
                .init(name: "metallic", dataType: .float, connection: metallic),
                .init(name: "normal", dataType: .vector3f, connection: normal),
                .init(name: "opacity", dataType: .float, connection: opacity),
                .init(name: "opacityThreshold", dataType: .float, connection: opacityThreshold),
                .init(name: "roughness", dataType: .float, connection: roughness),
                .init(name: "specular", dataType: .float, connection: specular),
            ],
            outputs: [
                .init(name: "out", dataType: .surface)
            ])
    }
}

public class SGGeometryModifier: SGNode {
    public init(modelPositionOffset: SGVector? = nil, normal: SGVector? = nil, color: SGColor? = nil, bitangent: SGVector? = nil, customAttribute: SGVector? = nil, uv0: SGVector? = nil, uv1: SGVector? = nil) {
        super.init(
            nodeType: "ND_realitykit_geometrymodifier_vertexshader",
            inputs: [
                .init(name: "modelPositionOffset", dataType: .vector3f, connection: modelPositionOffset),
                .init(name: "normal", dataType: .vector3f, connection: normal),
                .init(name: "color", dataType: .color4f, connection: color),
                .init(name: "bitangent", dataType: .vector3f, connection: bitangent),
                .init(name: "userAttribute", dataType: .vector4f, connection: customAttribute),
                .init(name: "uv0", dataType: .vector2f, connection: uv0),
                .init(name: "uv1", dataType: .vector2f, connection: uv1),
            ],
            outputs: [
                .init(name: "out", dataType: .geometryModifier)
            ])
    }
}

func collectParameters(nodes rootNodes: [SGNode]) -> [(String, SGConstantValue)] {
    var nodesToWrite: [SGNode] = rootNodes
    var nodesWritten: Set<SGNode> = []
    var parameters: [String: SGConstantValue] = [:]
    while nodesToWrite.count > 0 {
        let node = nodesToWrite[0]
        nodesToWrite.remove(at: 0)
        nodesWritten.insert(node)
        for i in node.inputs {
            if let c = i.value {
                if case .parameter(name: let name, defaultValue: let dv) = c.source {
                    parameters[name] = dv
                }
                else if case .nodeOutput(let inode, _) = c.source {
                    if !(nodesWritten.contains(inode) || nodesToWrite.contains(inode)) {
                        nodesToWrite.append(inode)
                    }
                }
            }
        }
    }
    return parameters.map { ($0.key, $0.value) }
}

func collectErrors(nodes rootNodes: [SGNode]) -> [String] {
    var nodesToWrite: [SGNode] = rootNodes
    var nodesWritten: Set<SGNode> = []
    var errors: [String] = []
    func queueValueInputNodes(v: SGValue) {
        if case .nodeOutput(let inode, _) = v.source {
            if !(nodesWritten.contains(inode) || nodesToWrite.contains(inode)) {
                nodesToWrite.append(inode)
            }
        }
        else if case .error(let e, let vals) = v.source {
            errors.append(e)
            for vv in vals {
                queueValueInputNodes(v: vv)
            }
        }
    }
    while nodesToWrite.count > 0 {
        let node = nodesToWrite[0]
        nodesToWrite.remove(at: 0)
        nodesWritten.insert(node)
        for i in node.inputs {
            if let c = i.value {
                queueValueInputNodes(v: c)
            }
        }
    }
    return errors
}
