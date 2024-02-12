//
//  ShaderGraphCoder.swift
//  HoloMap
//
//  Created by Frank A. Krueger on 2/10/24.
//

import Foundation
import RealityKit

class SGNode: Identifiable, Equatable, Hashable {
    private static var nextId: Int = 1
    let id: Int
    let nodeType: String
    let inputs: [Input]
    let outputs: [Output]
    let errors: [String]
    
    var dataType: SGDataType { outputs[0].dataType }
    var outputName: String { outputs[0].name }
    
    func getOutputValue(name: String) -> SGValueSource { .nodeOutput(self, name) }
    
    struct Input {
        let name: String
        let dataType: SGDataType
        let connection: SGValue?
        init(name: String, dataType: SGDataType, connection: SGValue?) {
            self.name = name
            self.dataType = dataType
            self.connection = connection
        }
        init(name: String, connection: SGValue) {
            self.name = name
            self.dataType = connection.dataType
            self.connection = connection
        }
    }
    
    struct Output {
        let name: String
        let dataType: SGDataType
        init(name: String, dataType: SGDataType) {
            self.name = name
            self.dataType = dataType
        }
        init(dataType: SGDataType) {
            self.name = "out"
            self.dataType = dataType
        }
    }
    
    init(nodeType: String, inputs: [Input], outputs: [Output], errors: [String] = []) {
        self.id = SGNode.nextId
        SGNode.nextId += 1
        self.nodeType = nodeType
        self.inputs = inputs
        self.outputs = outputs
        self.errors = errors
    }
    static func == (lhs: SGNode, rhs: SGNode) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine("n")
        hasher.combine(id)
    }

    func findOutput(name: String) -> Output? {
        outputs.first { $0.name == name }
    }
}

class SGValue {
    let source: SGValueSource
    var dataType: SGDataType { source.dataType }
    required init(source: SGValueSource) {
        self.source = source
    }
}

class SGString: SGValue {
    
}

class SGNumeric: SGValue {
    static func binary<T>(_ nodeType: String, left: SGNumeric, right: SGNumeric) -> T where T: SGNumeric {
        var errors: [String] = []
        var l = left
        var r = right
        if l.dataType.isScalar && !r.dataType.isScalar {
            switch nodeType {
            case "ND_multiply_":
                (l, r) = (r, l)
            case "ND_add_":
                (l, r) = (r, l)
            default:
                errors.append("\(l.dataType.usda) cannot be on the left hand side of \(r.dataType.usda) in \(nodeType)")
            }
        }
        let nodeDataType = inferBinaryOutputType(left: l.dataType, right: r.dataType)
        var nt = nodeType
        if nt.hasSuffix("_") {
            switch nodeDataType {
            case .asset:
                ()
            case .bool:
                nt += "bool"
            case .color3f:
                if r.dataType.isScalar {
                    nt += "color3FA"
                }
                else {
                    nt += "color3"
                }
            case .color4f:
                if r.dataType.isScalar {
                    nt += "color4FA"
                }
                else {
                    nt += "color4"
                }
            case .float:
                nt += "float"
            case .int:
                nt += "int"
            case .string:
                ()
            case .surface:
                ()
            case .vector2f:
                if r.dataType.isScalar {
                    nt += "vector2FA"
                }
                else {
                    nt += "vector2"
                }
            case .vector3f:
                if r.dataType.isScalar {
                    nt += "vector3FA"
                }
                else {
                    nt += "vector3"
                }
            case .vector4f:
                if r.dataType.isScalar {
                    nt += "vector4FA"
                }
                else {
                    nt += "vector4"
                }
            case .geometryModifier:
                ()
            }
        }
        let node = SGNode(
            nodeType: nt,
            inputs: [
                .init(name: "in1", connection: l),
                .init(name: "in2", connection: r),
            ],
            outputs: [.init(name: "out", dataType: nodeDataType)],
            errors: errors)
        return T(source: .nodeOutput(node, "out"))
    }
    static func unary<T>(_ nodeType: String, x: SGNumeric, dataType: SGDataType? = nil) -> T where T: SGNumeric {
        let nodeDataType = dataType ?? x.dataType
        var nt = nodeType
        if nt.hasSuffix("_") {
            switch nodeDataType {
            case .asset:
                ()
            case .bool:
                nt += "bool"
            case .color3f:
                nt += "color3FA"
            case .color4f:
                nt += "color4FA"
            case .float:
                nt += "float"
            case .int:
                nt += "int"
            case .string:
                ()
            case .surface:
                ()
            case .vector2f:
                nt += "vector2"
            case .vector3f:
                nt += "vector3"
            case .vector4f:
                nt += "vector4"
            case .geometryModifier:
                ()
            }
        }
        let node = SGNode(
            nodeType: nt,
            inputs: [
                .init(name: "in", connection: x),
            ],
            outputs: [.init(name: "out", dataType: nodeDataType)],
            errors: [])
        return T(source: .nodeOutput(node, "out"))
    }
    func add<T>(_ right: SGNumeric) -> T where T: SGNumeric {
        return SGNumeric.binary("ND_add_", left: self, right: right)
    }
    func subtract<T>(_ right: SGNumeric) -> T where T: SGNumeric {
        return SGNumeric.binary("ND_subtract_", left: self, right: right)
    }
    func multiply<T>(_ right: SGNumeric) -> T where T: SGNumeric {
        return SGNumeric.binary("ND_multiply_", left: self, right: right)
    }
    func divide<T>(_ right: SGNumeric) -> T where T: SGNumeric {
        return SGNumeric.binary("ND_divide_", left: self, right: right)
    }
}

class SGScalar: SGNumeric {
    static func + (left: SGScalar, right: SGScalar) -> SGScalar { left.add(right) }
    static func - (left: SGScalar, right: SGScalar) -> SGScalar { left.subtract(right) }
    static func * (left: SGScalar, right: SGScalar) -> SGScalar { left.multiply(right) }
    static func / (left: SGScalar, right: SGScalar) -> SGScalar { left.divide(right) }
    static func + (left: SGScalar, right: Float) -> SGScalar { left.add(.float(right)) }
    static func - (left: SGScalar, right: Float) -> SGScalar { left.subtract(.float(right)) }
    static func * (left: SGScalar, right: Float) -> SGScalar { left.multiply(.float(right)) }
    static func / (left: SGScalar, right: Float) -> SGScalar { left.divide(.float(right)) }
    static func + (left: Float, right: SGScalar) -> SGScalar { SGValue.float(left).add(right) }
    static func - (left: Float, right: SGScalar) -> SGScalar { SGValue.float(left).subtract(right) }
    static func * (left: Float, right: SGScalar) -> SGScalar { SGValue.float(left).multiply(right) }
    static func / (left: Float, right: SGScalar) -> SGScalar { SGValue.float(left).divide(right) }
}

class SGSIMD: SGNumeric {
    private var separate: SGNode? = nil
    func getSeparateOutput(_ name: String) -> SGScalar {
        if let esep = separate {
            return SGScalar(source: .nodeOutput(esep, name))
        }
        var errors: [String] = []
        var n = 3
        var type = "vector"
        var iscolor = false
        let elementType = SGDataType.float
        switch self.dataType {
        case .color3f:
            n = 3
            type = "color3"
            iscolor = true
        case .color4f:
            n = 4
            type = "color4"
            iscolor = true
        case .vector2f:
            n = 2
            type = "vector2"
        case .vector3f:
            n = 3
            type = "vector3"
        case .vector4f:
            n = 4
            type = "vector4"
        default:
            errors.append("Cannot separate \(self.dataType.usda)")
        }
        let inputs: [SGNode.Input] = [.init(name: "in", connection: self)]
        var outputs: [SGNode.Output] = []
        let names = iscolor ? ["outr", "outg", "outb", "outa"] : ["outx", "outy", "outz", "outw"]
        for i in 0..<n {
            outputs.append(.init(name: names[i], dataType: elementType))
        }
        let sep = SGNode(
            nodeType: "ND_separate\(n)_\(type)",
            inputs: inputs,
            outputs: outputs,
            errors: errors)
        separate = sep
        return SGScalar(source: .nodeOutput(sep, name))
    }
}

class SGVector: SGSIMD {
    static func + (left: SGVector, right: SGVector) -> SGVector { left.add(right) }
    static func - (left: SGVector, right: SGVector) -> SGVector { left.subtract(right) }
    static func * (left: SGVector, right: SGVector) -> SGVector { left.multiply(right) }
    static func / (left: SGVector, right: SGVector) -> SGVector { left.divide(right) }
    static func + (left: SGVector, right: SGScalar) -> SGVector { left.add(right) }
    static func - (left: SGVector, right: SGScalar) -> SGVector { left.subtract(right) }
    static func * (left: SGVector, right: SGScalar) -> SGVector { left.multiply(right) }
    static func / (left: SGVector, right: SGScalar) -> SGVector { left.divide(right) }
    static func + (left: SGVector, right: Float) -> SGVector { left.add(.float(right)) }
    static func - (left: SGVector, right: Float) -> SGVector { left.subtract(.float(right)) }
    static func * (left: SGVector, right: Float) -> SGVector { left.multiply(.float(right)) }
    static func / (left: SGVector, right: Float) -> SGVector { left.divide(.float(right)) }
    static func + (left: SGScalar, right: SGVector) -> SGVector { right.add(left) }
    static func * (left: SGScalar, right: SGVector) -> SGVector { right.multiply(left) }
    static func + (left: Float, right: SGVector) -> SGVector { right.add(.float(left)) }
    static func * (left: Float, right: SGVector) -> SGVector { right.multiply(.float(left)) }

    var x: SGScalar { getSeparateOutput("outx") }
    var y: SGScalar { getSeparateOutput("outy") }
    var z: SGScalar { getSeparateOutput("outz") }
    var w: SGScalar { getSeparateOutput("outw") }
    var xy: SGVector { combine(values: [x, y], dataType: .vector2f) }
    var xyz: SGVector { combine(values: [x, y, z], dataType: .vector3f) }
}

class SGColor: SGSIMD {
    static func + (left: SGColor, right: SGColor) -> SGColor { left.add(right) }
    static func - (left: SGColor, right: SGColor) -> SGColor { left.subtract(right) }
    static func * (left: SGColor, right: SGColor) -> SGColor { left.multiply(right) }
    static func / (left: SGColor, right: SGColor) -> SGColor { left.divide(right) }
    static func + (left: SGColor, right: SGScalar) -> SGColor { left.add(right) }
    static func - (left: SGColor, right: SGScalar) -> SGColor { left.subtract(right) }
    static func * (left: SGColor, right: SGScalar) -> SGColor { left.multiply(right) }
    static func / (left: SGColor, right: SGScalar) -> SGColor { left.divide(right) }
    static func + (left: SGColor, right: Float) -> SGColor { left.add(.float(right)) }
    static func - (left: SGColor, right: Float) -> SGColor { left.subtract(.float(right)) }
    static func * (left: SGColor, right: Float) -> SGColor { left.multiply(.float(right)) }
    static func / (left: SGColor, right: Float) -> SGColor { left.divide(.float(right)) }
    static func + (left: SGScalar, right: SGColor) -> SGColor { right.add(left) }
    static func * (left: SGScalar, right: SGColor) -> SGColor { right.multiply(left) }
    static func + (left: Float, right: SGColor) -> SGColor { right.add(.float(left)) }
    static func * (left: Float, right: SGColor) -> SGColor { right.multiply(.float(left)) }

    var r: SGScalar { getSeparateOutput("outr") }
    var g: SGScalar { getSeparateOutput("outg") }
    var b: SGScalar { getSeparateOutput("outb") }
    var a: SGScalar { getSeparateOutput("outa") }
    var rgb: SGColor { combine(values: [r, g, b], dataType: .color3f) }
    var bgr: SGColor { combine(values: [b, g, r], dataType: .color3f) }
}

class SGTexture1D: SGValue {
    func sample(texcoord: SGValue? = nil) -> SGColor {
        var errors: [String] = []
        if dataType != .asset {
            errors.append("Cannot sample `\(dataType.usda)`. Use a `texture1DParameter` to sample.")
        }
        let node = SGNode(
            nodeType: "ND_RealityKitTexture1D_color4",
            inputs: [
                .init(name: "file", dataType: .asset, connection: self),
                .init(name: "texcoord", dataType: .float, connection: texcoord),
            ],
            outputs: [.init(dataType: .color4f)])
        return SGColor(source: .nodeOutput(node))
    }
}

class SGTexture2D: SGValue {
    func sample(texcoord: SGValue? = nil) -> SGColor {
        var errors: [String] = []
        if dataType != .asset {
            errors.append("Cannot sample `\(dataType.usda)`. Use a `texture2DParameter` to sample.")
        }
        let node = SGNode(
            nodeType: "ND_RealityKitTexture2D_color4",
            inputs: [
                .init(name: "file", dataType: .asset, connection: self),
                .init(name: "texcoord", dataType: .vector2f, connection: texcoord),
            ],
            outputs: [.init(dataType: .color4f)])
        return SGColor(source: .nodeOutput(node))
    }
}

class SGTexture3D: SGValue {
    func sample(texcoord: SGValue? = nil) -> SGColor {
        var errors: [String] = []
        if dataType != .asset {
            errors.append("Cannot sample `\(dataType.usda)`. Use a `texture3DParameter` to sample.")
        }
        let node = SGNode(
            nodeType: "ND_RealityKitTexture3D_color4",
            inputs: [
                .init(name: "file", dataType: .asset, connection: self),
                .init(name: "texcoord", dataType: .vector3f, connection: texcoord),
            ],
            outputs: [.init(dataType: .color4f)])
        return SGColor(source: .nodeOutput(node))
    }
}

enum SGValueSource {
    case nodeOutput(_ node: SGNode, _ outputName: String)
    case constant(_ value: SGConstantValue)
    case parameter(name: String, defaultValue: SGConstantValue)
    
    var dataType: SGDataType {
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
        }
    }
}

enum SGDataType: String {
    case asset = "asset"
    case bool = "bool"
    case color3f = "color3f"
    case color4f = "color4f"
    case float = "float"
    case geometryModifier = "GeometryModifier"
    case int = "int"
    case string = "string"
    case surface = "Surface"
    case vector2f = "float2"
    case vector3f = "float3"
    case vector4f = "float4"
    
    var isScalar: Bool {
        switch self {
        case .asset:
            return false
        case .bool:
            return true
        case .color3f:
            return false
        case .color4f:
            return false
        case .float:
            return true
        case .int:
            return true
        case .string:
            return false
        case .surface:
            return false
        case .vector2f:
            return false
        case .vector3f:
            return false
        case .vector4f:
            return false
        case .geometryModifier:
            return false
        }
    }
    var isColor: Bool {
        switch self {
        case .asset:
            return false
        case .bool:
            return false
        case .color3f:
            return true
        case .color4f:
            return true
        case .float:
            return false
        case .int:
            return false
        case .string:
            return false
        case .surface:
            return false
        case .vector2f:
            return false
        case .vector3f:
            return false
        case .vector4f:
            return false
        case .geometryModifier:
            return false
        }
    }
}

enum SGConstantValue {
    case color3f(_ value: SIMD3<Float>, colorSpace: SGColorSpace)
    case color4f(_ value: SIMD4<Float>, colorSpace: SGColorSpace)
    case emptyTexture1D
    case emptyTexture2D
    case emptyTexture3D
    case float(_ value: Float)
    case string(_ value: String)
    case vector2f(_ value: SIMD2<Float>)
    case vector3f(_ value: SIMD3<Float>)
    case vector4f(_ value: SIMD4<Float>)
    var dataType: SGDataType {
        switch self {
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
        case .string:
            return .string
        case .vector2f:
            return .vector2f
        case .vector3f:
            return .vector3f
        case .vector4f:
            return .vector4f
        }
    }
}

enum SGColorSpace: String {
    case linearSRGB = "lin_srgb"
    case textureSRGB = "srgb_texture"
}

extension SGValue {
    static func color3f(_ value: SIMD3<Float>, colorSpace: SGColorSpace = .textureSRGB) -> SGColor {
        SGColor(source: .constant(.color3f(value, colorSpace: colorSpace)))
    }
    static func color3f(_ x: Float, _ y: Float, _ z: Float, colorSpace: SGColorSpace = .textureSRGB) -> SGColor {
        SGColor(source: .constant(.color3f([x, y, z], colorSpace: colorSpace)))
    }
    static func color3fParameter(name: String, defaultValue: SIMD3<Float>, colorSpace: SGColorSpace = .textureSRGB) -> SGColor {
        SGColor(source: .parameter(name: name, defaultValue: .color3f(defaultValue, colorSpace: colorSpace)))
    }
    static func float(_ value: Float) -> SGScalar {
        SGScalar(source: .constant(.float(value)))
    }
    static func floatParameter(name: String, defaultValue: Float) -> SGScalar {
        SGScalar(source: .parameter(name: name, defaultValue: .float(defaultValue)))
    }
    static func texture1DParameter(name: String) -> SGTexture1D {
        SGTexture1D(source: .parameter(name: name, defaultValue: .emptyTexture1D))
    }
    static func texture2DParameter(name: String) -> SGTexture2D {
        SGTexture2D(source: .parameter(name: name, defaultValue: .emptyTexture2D))
    }
    static func texture3DParameter(name: String) -> SGTexture3D {
        SGTexture3D(source: .parameter(name: name, defaultValue: .emptyTexture3D))
    }
    static func string(_ value: String) -> SGString {
        SGString(source: .constant(.string(value)))
    }
    static var time: SGScalar {
        SGScalar(source: SGValueSource.nodeOutput(SGNode.time, "out"))
    }
    static func vector2f(_ value: SIMD2<Float>) -> SGVector {
        SGVector(source: .constant(.vector2f(value)))
    }
    static func vector2f(_ x: Float, _ y: Float) -> SGVector {
        SGVector(source: .constant(.vector2f([x, y])))
    }
    static func vector3f(_ value: SIMD3<Float>) -> SGVector {
        SGVector(source: .constant(.vector3f(value)))
    }
    static func vector3f(_ x: Float, _ y: Float, _ z: Float) -> SGVector {
        SGVector(source: .constant(.vector3f([x, y, z])))
    }
    static func vector4f(_ value: SIMD4<Float>) -> SGVector {
        SGVector(source: .constant(.vector4f(value)))
    }
    static func vector4f(_ x: Float, _ y: Float, _ z: Float, _ w: Float) -> SGVector {
        SGVector(source: .constant(.vector4f([x, y, z, w])))
    }
    static var worldCameraPosition: SGVector {
        SGVector(source: SGValueSource.nodeOutput(SGNode.worldCameraPosition, "out"))
    }
    static var worldPosition: SGVector {
        SGVector(source: SGValueSource.nodeOutput(SGNode.worldPosition, "out"))
    }
    static var worldNormal: SGVector {
        SGVector(source: SGValueSource.nodeOutput(SGNode.worldNormal, "out"))
    }
}

func color3f(_ r: SGScalar, _ g: SGScalar, _ b: SGScalar) -> SGColor {
    return combine(values: [r, g, b], dataType: .color3f)
}

func color4f(_ r: SGScalar, _ g: SGScalar, _ b: SGScalar, _ a: SGScalar) -> SGColor {
    return combine(values: [r, g, b, a], dataType: .color4f)
}

private func getNodeSuffixForDataType(_ dataType: SGDataType) -> String {
    switch dataType {
    case .color3f:
        return "color3"
    case .color4f:
        return "color4"
    case .float:
        return "float"
    case .vector2f:
        return "vector2"
    case .vector3f:
        return "vector3"
    case .vector4f:
        return "vector4"
    case .asset:
        return "asset"
    case .bool:
        return "bool"
    case .geometryModifier:
        return "token"
    case .int:
        return "int"
    case .string:
        return "string"
    case .surface:
        return "token"
    }
}

func combine<T>(values: [SGScalar], dataType: SGDataType) -> T where T: SGSIMD {
    var errors: [String] = []
    var n = 3
    let type = getNodeSuffixForDataType(dataType)
    let elementType = SGDataType.float
    switch dataType {
    case .color3f:
        n = 3
    case .color4f:
        n = 4
    case .vector2f:
        n = 2
    case .vector3f:
        n = 3
    case .vector4f:
        n = 4
    default:
        errors.append("Cannot combine \(dataType.usda)")
    }
    var inputs: [SGNode.Input] = []
    if values.count != n {
        errors.append("Expected \(n) values for combine, but got \(values.count).")
    }
    for i in 0..<n {
        inputs.append(.init(name: "in\(i+1)", dataType: elementType, connection: i < values.count ? values[i] : nil))
    }
    let outputs: [SGNode.Output] = [.init(dataType: dataType)]
    let sep = SGNode(
        nodeType: "ND_combine\(n)_\(type)",
        inputs: inputs,
        outputs: outputs)
    return T(source: .nodeOutput(sep))
}

func abs<T>(_ x: T) -> T where T: SGNumeric {
    SGNumeric.unary("ND_absval_", x: x)
}

func clamp<T>(_ x: T, min: T, max: T) -> T where T: SGNumeric {
    let node = SGNode(
        nodeType: "ND_clamp_" + getNodeSuffixForDataType(x.dataType),
        inputs: [
            .init(name: "in", connection: x),
            .init(name: "high", connection: max),
            .init(name: "low", connection: min),
        ],
        outputs: [.init(dataType: x.dataType)])
    return T(source: .nodeOutput(node))
}

func clamp(_ x: SGScalar, min: Float, max: Float) -> SGScalar {
    clamp(x, min: SGValue.float(min), max: SGValue.float(max))
}

func cos<T>(_ x: T) -> T where T: SGNumeric {
    SGNumeric.unary("ND_cos_", x: x)
}

func ifGreaterOrEqual<T, U>(_ value1: T, _ value2: T, trueResult: U, falseResult: U) -> U where T: SGNumeric, U: SGValue {
    let node = SGNode(
        nodeType: "ND_ifgreatereq_" + getNodeSuffixForDataType(trueResult.dataType),
        inputs: [
            .init(name: "in1", connection: trueResult),
            .init(name: "in2", connection: falseResult),
            .init(name: "value1", connection: value1),
            .init(name: "value2", connection: value2),
        ],
        outputs: [.init(dataType: trueResult.dataType)])
    return U(source: .nodeOutput(node))
}

func ifGreaterOrEqual<T>(_ value1: T, _ value2: T, trueResult: Float, falseResult: Float) -> SGScalar where T: SGNumeric {
    ifGreaterOrEqual(value1, value2, trueResult: .float(trueResult), falseResult: .float(falseResult))
}

func ifLess<T, U>(_ value1: T, _ value2: T, trueResult: U, falseResult: U) -> U where T: SGNumeric, U: SGValue {
    ifGreaterOrEqual(value2, value1, trueResult: trueResult, falseResult: falseResult)
}

func ifLess<T>(_ value1: T, _ value2: T, trueResult: Float, falseResult: Float) -> SGScalar where T: SGNumeric {
    ifGreaterOrEqual(value2, value1, trueResult: .float(trueResult), falseResult: .float(falseResult))
}

func length<T>(_ x: T) -> SGScalar where T: SGSIMD {
    let node = SGNode(
        nodeType: "ND_magnitude_" + getNodeSuffixForDataType(x.dataType),
        inputs: [.init(name: "in", connection: x)],
        outputs: [.init(dataType: .float)])
    return SGScalar(source: .nodeOutput(node))
}

func mix<T, U>(_ x: T, _ y: T, t: U) -> T where T: SGNumeric, U: SGNumeric {
    let node = SGNode(
        nodeType: "ND_mix_" + getNodeSuffixForDataType(x.dataType),
        inputs: [
            .init(name: "bg", connection: x), // when t = 0
            .init(name: "fg", connection: y), // when t = 1
            .init(name: "mix", connection: t),
        ],
        outputs: [.init(dataType: x.dataType)])
    return T(source: .nodeOutput(node))
}

func pow<T>(_ x: T, _ y: SGNumeric) -> T where T: SGNumeric {
    SGNumeric.binary("ND_power_", left: x, right: y)
}

func pow<T>(_ x: T, _ y: Float) -> T where T: SGNumeric {
    SGNumeric.binary("ND_power_", left: x, right: .float(y))
}

func sin<T>(_ x: T) -> T where T: SGNumeric {
    SGNumeric.unary("ND_sin_", x: x)
}

func vector2f(_ x: SGScalar, _ y: SGScalar) -> SGVector {
    return combine(values: [x, y], dataType: .vector2f)
}

func vector3f(_ x: SGScalar, _ y: SGScalar, _ z: SGScalar) -> SGVector {
    return combine(values: [x, y, z], dataType: .vector3f)
}

func vector4f(_ x: SGScalar, _ y: SGScalar, _ z: SGScalar, _ w: SGScalar) -> SGVector {
    return combine(values: [x, y, z, w], dataType: .vector4f)
}

extension SGNode {
    static let time = SGNode(nodeType: "ND_time_float", inputs: [], outputs: [.init(name: "out", dataType: .float)])
    static let worldCameraPosition = SGNode(nodeType: "ND_realitykit_cameraposition_vector3", inputs: [], outputs: [.init(name: "out", dataType: .vector3f)])
    static let worldPosition = SGNode(nodeType: "ND_position_vector3", inputs: [.init(name: "space", connection: .string("world"))], outputs: [.init(name: "out", dataType: .vector3f)])
    static let worldNormal = SGNode(nodeType: "ND_normal_vector3", inputs: [.init(name: "space", connection: .string("world"))], outputs: [.init(name: "out", dataType: .vector3f)])
}

private func inferBinaryOutputType(left: SGDataType, right: SGDataType) -> SGDataType {
    if left.isScalar {
        return right
    }
    return left
}

extension SGValueSource {
    static func nodeOutput(_ node: SGNode) -> SGValueSource {
        .nodeOutput(node, "out")
    }
}

class SGSurface: SGNode {
}

class SGGeometryModifier: SGNode {
    init(modelPositionOffset: SGVector? = nil, normal: SGVector? = nil, color: SGColor? = nil, bitangent: SGVector? = nil, userAttribute: SGVector? = nil, uv0: SGVector? = nil, uv1: SGVector? = nil) {
        super.init(
            nodeType: "ND_realitykit_geometrymodifier_vertexshader",
            inputs: [
                .init(name: "modelPositionOffset", dataType: .vector3f, connection: modelPositionOffset),
                .init(name: "normal", dataType: .vector3f, connection: normal),
                .init(name: "color", dataType: .color4f, connection: color),
                .init(name: "bitangent", dataType: .vector3f, connection: bitangent),
                .init(name: "userAttribute", dataType: .vector4f, connection: userAttribute),
                .init(name: "uv0", dataType: .vector2f, connection: uv0),
                .init(name: "uv1", dataType: .vector2f, connection: uv1),
            ],
            outputs: [
                .init(name: "out", dataType: .geometryModifier)
            ])
    }
}

class SGPBRSurface: SGSurface {
    init(baseColor: SGColor? = nil, roughness: SGScalar? = nil, metallic: SGScalar? = nil, emissiveColor: SGColor? = nil, ambientOcclusion: SGScalar? = nil, clearcoat: SGScalar? = nil, clearcoatRoughness: SGScalar? = nil, normal: SGVector? = nil, hasPremultipliedAlpha: SGScalar? = nil, opacity: SGScalar? = nil, opacityThreshold: SGScalar? = nil, specular: SGScalar? = nil) {
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

extension SGNode {
    var usdaName: String { "Node\(id)" }
}

extension SGDataType {
    var usda: String {
        switch self {
        case .surface:
            return "token"
        case .geometryModifier:
            return "token"
        default:
            return self.rawValue
        }
    }
}

extension SGConstantValue {
    var usda: String {
        switch self {
        case .color3f(let v, colorSpace: let cs):
            return "(\(v.x), \(v.y), \(v.z)) (colorSpace = \"\(cs.rawValue)\")"
        case .color4f(let v, colorSpace: let cs):
            return "(\(v.x), \(v.y), \(v.z), \(v.w)) (colorSpace = \"\(cs.rawValue)\")"
        case .emptyTexture1D:
            return "\"\""
        case .emptyTexture2D:
            return "\"\""
        case .emptyTexture3D:
            return "\"\""
        case .string(let v):
            return "\"\(v)\""
        case .vector2f(let v):
            return "(\(v.x), \(v.y))"
        case .vector3f(let v):
            return "(\(v.x), \(v.y), \(v.z))"
        case .vector4f(let v):
            return "(\(v.x), \(v.y), \(v.z), \(v.w)"
        case .float(let v):
            return "\(v)"
        }
    }
}

extension SGValueSource {
    func getUSDAReference(materialName: String) -> String {
        switch self {
        case .constant(let ivalue):
            return ivalue.usda
        case .nodeOutput(let inode, let inodeOut):
            return "</Root/\(materialName)/\(inode.usdaName).outputs:\(inodeOut)>"
        case .parameter(name: let name, defaultValue: _):
            return "</Root/\(materialName).inputs:\(name)>"
        }
    }
}

private func collectParameters(nodes rootNodes: [SGNode]) -> [(String, SGConstantValue)] {
    var nodesToWrite: [SGNode] = rootNodes
    var nodesWritten: Set<SGNode> = []
    var parameters: [String: SGConstantValue] = [:]
    while nodesToWrite.count > 0 {
        let node = nodesToWrite[0]
        nodesToWrite.remove(at: 0)
        nodesWritten.insert(node)
        for i in node.inputs {
            if let c = i.connection {
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

private func collectErrors(nodes rootNodes: [SGNode]) -> [String] {
    var nodesToWrite: [SGNode] = rootNodes
    var nodesWritten: Set<SGNode> = []
    var errors: [String] = []
    while nodesToWrite.count > 0 {
        let node = nodesToWrite[0]
        nodesToWrite.remove(at: 0)
        nodesWritten.insert(node)
        errors.append(contentsOf: node.errors)
        for i in node.inputs {
            if let c = i.connection?.source {
                if case .nodeOutput(let inode, _) = c {
                    if !(nodesWritten.contains(inode) || nodesToWrite.contains(inode)) {
                        nodesToWrite.append(inode)
                    }
                }
            }
        }
    }
    return errors
}

func getUSDA(materialName: String, surface: SGSurface?, geometryModifier: SGGeometryModifier?) -> (String, [String]) {
    var lines: [String] = []
    func line(_ text: String) {
        lines.append(text)
    }
    line("#usda 1.0")
    line("(")
    line("    defaultPrim = \"Root\"")
    line("    metersPerUnit = 1")
    line("    upAxis = \"Y\"")
    line(")")
    line("")
    line("def Xform \"Root\"")
    line("{")
    line("    reorder nameChildren = [\"\(materialName)\"]")
    line("    def Material \"\(materialName)\"")
    line("    {")
    
    let outputNodes = [surface, geometryModifier].compactMap { $0 }
    let parameters = collectParameters(nodes: outputNodes)
    let errors = collectErrors(nodes: outputNodes)
    for p in parameters {
        let (name, defaultValue) = p
        line("        \(defaultValue.dataType.usda) inputs:\(name) = \(defaultValue.usda)")
    }
    
    if let s = surface {
        let v = s.getOutputValue(name: "out").getUSDAReference(materialName: materialName)
        line("        token outputs:mtlx:surface.connect = \(v)")
    }
    else {
        line("        token outputs:mtlx:surface")
    }
    if let g = geometryModifier {
        let v = g.getOutputValue(name: "out").getUSDAReference(materialName: materialName)
        line("        token outputs:realitykit:vertex.connect = \(v)")
    }
    else {
        line("        token outputs:realitykit:vertex")
    }
    
    var nodesToWrite: [SGNode] = outputNodes
    var nodesWritten: Set<SGNode> = []
    while nodesToWrite.count > 0 {
        let node = nodesToWrite[0]
        nodesToWrite.remove(at: 0)
        nodesWritten.insert(node)
        line("")
        line("        def Shader \"\(node.usdaName)\"")
        line("        {")
        line("            uniform token info:id = \"\(node.nodeType)\"")
        for i in node.inputs {
            var decl = "\(i.dataType.usda) inputs:\(i.name)"
            if let c = i.connection?.source {
                if case .nodeOutput = c {
                    decl += ".connect"
                }
                else if case .parameter = c {
                    decl += ".connect"
                }
            }
            if let value = i.connection?.source.getUSDAReference(materialName: materialName) {
                line("            \(decl) = \(value)")
            }
            else {
                line("            \(decl)")
            }
        }
        for o in node.outputs {
            let decl = "\(o.dataType.usda) outputs:\(o.name)"
            line("            \(decl)")
        }
        line("        }")
        for i in node.inputs {
            if case .nodeOutput(let inode, _) = i.connection?.source {
                if !(nodesWritten.contains(inode) || nodesToWrite.contains(inode)) {
                    nodesToWrite.append(inode)
                }
            }
        }
    }
    
    line("    }")
    line("}")
    
    return (lines.joined(separator: "\n"), errors)
}

extension SGSurface {
    func usda(materialName: String) -> String {
        return getUSDA(materialName: materialName, surface: self, geometryModifier: nil).0
    }
    func loadMaterial() async throws -> ShaderGraphMaterial {
        return try await ShaderGraphMaterial(surface: self, geometryModifier: nil)
    }
}

extension SGGeometryModifier {
    func usda(materialName: String) -> String {
        return getUSDA(materialName: materialName, surface: nil, geometryModifier: self).0
    }
    func loadMaterial() async throws -> ShaderGraphMaterial {
        return try await ShaderGraphMaterial(surface: nil, geometryModifier: self)
    }
}

extension ShaderGraphMaterial {
    init(surface: SGSurface?, geometryModifier: SGGeometryModifier?) async throws {
        let materialName = "ShaderGraphCoderMaterial"
        let (usda, errors) = getUSDA(materialName: materialName, surface: surface, geometryModifier: geometryModifier)
        if errors.count > 0 {
            throw ShaderGraphCoderError.graphContainsErrors(errors: errors)
        }
        guard let usdaData = usda.data(using: .utf8) else {
            throw ShaderGraphCoderError.failedToEncodeUSDAsData
        }
        print("\n\n========\nUSDA\n========\n\(usda)\n")
        try await self.init(named: "/Root/\(materialName)", from: usdaData)
    }
}

enum ShaderGraphCoderError: Error {
    case failedToEncodeUSDAsData
    case graphContainsErrors(errors: [String])
}


// ========
// TESTS
// ========

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
