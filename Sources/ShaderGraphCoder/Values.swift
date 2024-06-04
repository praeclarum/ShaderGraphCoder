//
//  ShaderGraphCoder.swift
//  ShaderGraphCoder
//
//  Created by Frank A. Krueger on 2/10/24.
//

import Foundation
import RealityKit

public class SGNumeric: SGValue {
    func add<T>(_ right: SGNumeric) -> T where T: SGNumeric {
        return binop("ND_add_", left: self, right: right)
    }
    func subtract<T>(_ right: SGNumeric) -> T where T: SGNumeric {
        return binop("ND_subtract_", left: self, right: right)
    }
    func multiply<T>(_ right: SGNumeric) -> T where T: SGNumeric {
        return binop("ND_multiply_", left: self, right: right)
    }
    func divide<T>(_ right: SGNumeric) -> T where T: SGNumeric {
        return binop("ND_divide_", left: self, right: right)
    }
    func modulo<T>(_ right: SGNumeric) -> T where T: SGNumeric {
        return binop("ND_modulo_", left: self, right: right)
    }
}

public class SGScalar: SGNumeric {
    public static func + (left: SGScalar, right: SGScalar) -> SGScalar { left.add(right) }
    public static func - (left: SGScalar, right: SGScalar) -> SGScalar { left.subtract(right) }
    public static func * (left: SGScalar, right: SGScalar) -> SGScalar { left.multiply(right) }
    public static func / (left: SGScalar, right: SGScalar) -> SGScalar { left.divide(right) }
    public static func % (left: SGScalar, right: SGScalar) -> SGScalar { binop("ND_modulo_", left: left, right: right) }
    public static func + (left: SGScalar, right: Float) -> SGScalar { left.add(.float(right)) }
    public static func - (left: SGScalar, right: Float) -> SGScalar { left.subtract(.float(right)) }
    public static func * (left: SGScalar, right: Float) -> SGScalar { left.multiply(.float(right)) }
    public static func / (left: SGScalar, right: Float) -> SGScalar { left.divide(.float(right)) }
    public static func % (left: SGScalar, right: Float) -> SGScalar { left % .float(right) }
    public static func + (left: Float, right: SGScalar) -> SGScalar { SGValue.float(left).add(right) }
    public static func - (left: Float, right: SGScalar) -> SGScalar { SGValue.float(left).subtract(right) }
    public static func * (left: Float, right: SGScalar) -> SGScalar { SGValue.float(left).multiply(right) }
    public static func / (left: Float, right: SGScalar) -> SGScalar { SGValue.float(left).divide(right) }
    public static func % (left: Float, right: SGScalar) -> SGScalar { SGValue.float(left) % right }
}

public class SGSIMD: SGNumeric {
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
        let names = iscolor ? ["outr", "outg", "outb", "outa"] : (n < 4 ? ["outx", "outy", "outz"] : ["outw", "outx", "outy", "outz"])
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

public class SGVector: SGSIMD {
    public static func + (left: SGVector, right: SGVector) -> SGVector { left.add(right) }
    public static func - (left: SGVector, right: SGVector) -> SGVector { left.subtract(right) }
    public static func * (left: SGVector, right: SGVector) -> SGVector { left.multiply(right) }
    public static func / (left: SGVector, right: SGVector) -> SGVector { left.divide(right) }
    public static func % (left: SGVector, right: SGVector) -> SGVector { left.modulo(right) }
    public static func + (left: SGVector, right: SGScalar) -> SGVector { left.add(right) }
    public static func - (left: SGVector, right: SGScalar) -> SGVector { left.subtract(right) }
    public static func * (left: SGVector, right: SGScalar) -> SGVector { left.multiply(right) }
    public static func / (left: SGVector, right: SGScalar) -> SGVector { left.divide(right) }
    public static func % (left: SGVector, right: SGScalar) -> SGVector { left.modulo(right) }
    public static func + (left: SGVector, right: Float) -> SGVector { left.add(.float(right)) }
    public static func - (left: SGVector, right: Float) -> SGVector { left.subtract(.float(right)) }
    public static func * (left: SGVector, right: Float) -> SGVector { left.multiply(.float(right)) }
    public static func / (left: SGVector, right: Float) -> SGVector { left.divide(.float(right)) }
    public static func % (left: SGVector, right: Float) -> SGVector { left.modulo(.float(right)) }
    public static func + (left: SGScalar, right: SGVector) -> SGVector { right.add(left) }
    public static func * (left: SGScalar, right: SGVector) -> SGVector { right.multiply(left) }
    public static func + (left: Float, right: SGVector) -> SGVector { right.add(.float(left)) }
    public static func * (left: Float, right: SGVector) -> SGVector { right.multiply(.float(left)) }

    public var x: SGScalar { getSeparateOutput("outx") }
    public var y: SGScalar { getSeparateOutput("outy") }
    public var z: SGScalar { getSeparateOutput("outz") }
    public var w: SGScalar { getSeparateOutput("outw") }
    public var xy: SGVector { combine(values: [x, y], dataType: .vector2f) }
    public var xyz: SGVector { combine(values: [x, y, z], dataType: .vector3f) }
}

public class SGColor: SGSIMD {
    public static func + (left: SGColor, right: SGColor) -> SGColor { left.add(right) }
    public static func - (left: SGColor, right: SGColor) -> SGColor { left.subtract(right) }
    public static func * (left: SGColor, right: SGColor) -> SGColor { left.multiply(right) }
    public static func / (left: SGColor, right: SGColor) -> SGColor { left.divide(right) }
    public static func % (left: SGColor, right: SGColor) -> SGColor { left.modulo(right) }
    public static func + (left: SGColor, right: SGScalar) -> SGColor { left.add(right) }
    public static func - (left: SGColor, right: SGScalar) -> SGColor { left.subtract(right) }
    public static func * (left: SGColor, right: SGScalar) -> SGColor { left.multiply(right) }
    public static func / (left: SGColor, right: SGScalar) -> SGColor { left.divide(right) }
    public static func % (left: SGColor, right: SGScalar) -> SGColor { left.modulo(right) }
    public static func + (left: SGColor, right: Float) -> SGColor { left.add(.float(right)) }
    public static func - (left: SGColor, right: Float) -> SGColor { left.subtract(.float(right)) }
    public static func * (left: SGColor, right: Float) -> SGColor { left.multiply(.float(right)) }
    public static func / (left: SGColor, right: Float) -> SGColor { left.divide(.float(right)) }
    public static func % (left: SGColor, right: Float) -> SGColor { left.modulo(.float(right)) }
    public static func + (left: SGScalar, right: SGColor) -> SGColor { right.add(left) }
    public static func * (left: SGScalar, right: SGColor) -> SGColor { right.multiply(left) }
    public static func + (left: Float, right: SGColor) -> SGColor { right.add(.float(left)) }
    public static func * (left: Float, right: SGColor) -> SGColor { right.multiply(.float(left)) }

    public var r: SGScalar { getSeparateOutput("outr") }
    public var g: SGScalar { getSeparateOutput("outg") }
    public var b: SGScalar { getSeparateOutput("outb") }
    public var a: SGScalar { getSeparateOutput("outa") }
    public var rgb: SGColor { combine(values: [r, g, b], dataType: .color3f) }
    public var bgr: SGColor { combine(values: [b, g, r], dataType: .color3f) }
}

public class SGString: SGValue {
    
}

public class SGTexture: SGValue {
    
}

public class SGTexture1D: SGTexture {
    public func sample(texcoord: SGValue? = nil) -> SGColor {
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

public class SGTexture2D: SGTexture {
    public func sample(texcoord: SGValue? = nil) -> SGColor {
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

public class SGTexture3D: SGTexture {
    public func sample(texcoord: SGValue? = nil) -> SGColor {
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

public class SGMatrix: SGNumeric {
    
}

public protocol SGErrorValue {
}

public class SGColorError: SGColor, SGErrorValue {
    public init(_ error: String) {
        super.init(source: .constant(.string(error)))
    }
    public required init(source: SGValueSource) {
        super.init(source: source)
    }
}

public class SGMatrixError: SGMatrix, SGErrorValue {
    public init(_ error: String) {
        super.init(source: .constant(.string(error)))
    }
    public required init(source: SGValueSource) {
        super.init(source: source)
    }
}

public class SGNumericError: SGNumeric, SGErrorValue {
    public init(_ error: String) {
        super.init(source: .constant(.string(error)))
    }
    public required init(source: SGValueSource) {
        super.init(source: source)
    }
}

public class SGScalarError: SGScalar, SGErrorValue {
    public init(_ error: String) {
        super.init(source: .constant(.string(error)))
    }
    public required init(source: SGValueSource) {
        super.init(source: source)
    }
}

public class SGValueError: SGValue, SGErrorValue {
    public init(_ error: String) {
        super.init(source: .constant(.string(error)))
    }
    public required init(source: SGValueSource) {
        super.init(source: source)
    }
}

public class SGVectorError: SGVector, SGErrorValue {
    public init(_ error: String) {
        super.init(source: .constant(.string(error)))
    }
    public required init(source: SGValueSource) {
        super.init(source: source)
    }
}
