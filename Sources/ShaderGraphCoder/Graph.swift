//
//  Graph.swift
//  ShaderGraphCoder
//
//  Created by Frank A. Krueger on 2/10/24.
//

import CoreGraphics
import Foundation
import RealityKit
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
    case error(_ error: String, values: [SGValue?])
    
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
    
    public var node: SGNode? {
        switch self {
        case .nodeOutput(let node, _):
            return node
        default:
            return nil
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
    case int = "int"
    case matrix2d = "matrix2d"
    case matrix3d = "matrix3d"
    case matrix4d = "matrix4d"
    case string = "string"
    case token = "token"
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
    /// Returns true if the provided value's dataType matches this dataType.
    /// If the value is nil, this function returns true.
    public func matches(_ value: SGValue?) -> Bool {
        if let v = value {
            return v.dataType == self
        }
        return true
    }
}

public enum SGTextureSource {
    case texture(_ texture: TextureResource)
    case generate(from: CGImage, options: TextureResource.CreateOptions)
    case loadNamed(_ named: String, in: Bundle?, options: TextureResource.CreateOptions?)
    case loadContentsOf(_ url: URL, options: TextureResource.CreateOptions?)
    
    func loadTextureResource() throws -> TextureResource {
        switch self {
        case .texture(let t):
            return t
        case .generate(let from, let options):
            return try TextureResource.generate(from: from, options: options)
        case .loadNamed(let named, let bundle, .some(let options)):
            return try TextureResource.load(named: named, in: bundle, options: options)
        case .loadNamed(let named, let bundle, .none):
            return try TextureResource.load(named: named, in: bundle)
        case .loadContentsOf(let url, .some(let options)):
            return try TextureResource.load(contentsOf: url, options: options)
        case .loadContentsOf(let url, .none):
            return try TextureResource.load(contentsOf: url)
        }
    }
}

public enum SGConstantValue {
    case bool(_ value: Bool)
    case color3f(_ value: SIMD3<Float>, colorSpace: SGColorSpace?)
    case color4f(_ value: SIMD4<Float>, colorSpace: SGColorSpace?)
    case emptyTexture
    case float(_ value: Float)
    case half(_ value: Float16)
    case int(_ value: Int)
    case matrix2d(_ value: simd_float2x2)
    case matrix3d(_ value: simd_float3x3)
    case matrix4d(_ value: simd_float4x4)
    case vector2f(_ value: SIMD2<Float>)
    case vector3f(_ value: SIMD3<Float>)
    case vector4f(_ value: SIMD4<Float>)
    case vector2h(_ value: SIMD2<Float16>)
    case vector3h(_ value: SIMD3<Float16>)
    case vector4h(_ value: SIMD4<Float16>)
    case vector2i(_ value: SIMD2<Int>)
    case vector3i(_ value: SIMD3<Int>)
    case vector4i(_ value: SIMD4<Int>)
    case string(_ value: String)
    case texture(_ value: SGTextureSource)
    case token(_ value: String)
    public var dataType: SGDataType {
        switch self {
        case .bool:
            return .bool
        case .color3f:
            return .color3f
        case .color4f:
            return .color4f
        case .emptyTexture:
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
        case .texture:
            return .asset
        case .token:
            return .token
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

func collectErrors(values rootValues: [SGValue?]) -> [String] {
    var nodesToWrite: [SGNode] = []
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
            for vvo in vals {
                if let vv = vvo {
                    queueValueInputNodes(v: vv)
                }
            }
        }
    }
    for r in rootValues {
        if let rr = r {
            queueValueInputNodes(v: rr)
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
