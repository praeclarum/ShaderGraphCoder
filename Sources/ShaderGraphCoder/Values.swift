//
//  ShaderGraphCoder.swift
//  ShaderGraphCoder
//
//  Created by Frank A. Krueger on 2/10/24.
//

import Foundation
import RealityKit

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
    private static func inferBinaryOutputType(left: SGDataType, right: SGDataType) -> SGDataType {
        if left.isScalar {
            return right
        }
        return left
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

class SGString: SGValue {
    
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
