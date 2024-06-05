//
//  ShaderGraphCoder.swift
//  ShaderGraphCoder
//
//  Created by Frank A. Krueger on 2/10/24.
//

import Foundation
import RealityKit

public class SGNumeric: SGValue {
}

public class SGScalar: SGNumeric {
    public static func + (left: SGScalar, right: SGScalar) -> SGScalar { ShaderGraphCoder.add(left, right) }
    public static func - (left: SGScalar, right: SGScalar) -> SGScalar { ShaderGraphCoder.subtract(left, right) }
    public static func * (left: SGScalar, right: SGScalar) -> SGScalar { ShaderGraphCoder.multiply(left, right) }
    public static func / (left: SGScalar, right: SGScalar) -> SGScalar { ShaderGraphCoder.divide(left, right) }
    public static func % (left: SGScalar, right: SGScalar) -> SGScalar { ShaderGraphCoder.modulo(left, right) }
    public static func + (left: SGScalar, right: Float) -> SGScalar { ShaderGraphCoder.add(left, .float(right)) }
    public static func - (left: SGScalar, right: Float) -> SGScalar { ShaderGraphCoder.subtract(left, .float(right)) }
    public static func * (left: SGScalar, right: Float) -> SGScalar { ShaderGraphCoder.multiply(left, .float(right)) }
    public static func / (left: SGScalar, right: Float) -> SGScalar { ShaderGraphCoder.divide(left, .float(right)) }
    public static func % (left: SGScalar, right: Float) -> SGScalar { ShaderGraphCoder.modulo(left, .float(right)) }
    public static func + (left: Float, right: SGScalar) -> SGScalar { ShaderGraphCoder.add(.float(left), right) }
    public static func - (left: Float, right: SGScalar) -> SGScalar { ShaderGraphCoder.subtract(.float(left), right) }
    public static func * (left: Float, right: SGScalar) -> SGScalar { ShaderGraphCoder.multiply(.float(left), right) }
    public static func / (left: Float, right: SGScalar) -> SGScalar { ShaderGraphCoder.divide(.float(left), right) }
    public static func % (left: Float, right: SGScalar) -> SGScalar { ShaderGraphCoder.modulo(.float(left), right) }
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
    public static func + (left: SGVector, right: SGVector) -> SGVector { ShaderGraphCoder.add(left, right) }
    public static func - (left: SGVector, right: SGVector) -> SGVector { ShaderGraphCoder.subtract(left, right) }
    public static func * (left: SGVector, right: SGVector) -> SGVector { ShaderGraphCoder.multiply(left, right) }
    public static func / (left: SGVector, right: SGVector) -> SGVector { ShaderGraphCoder.divide(left, right) }
    public static func % (left: SGVector, right: SGVector) -> SGVector { ShaderGraphCoder.modulo(left, right) }
    public static func + (left: SGVector, right: SGScalar) -> SGVector { ShaderGraphCoder.add(left, right) }
    public static func - (left: SGVector, right: SGScalar) -> SGVector { ShaderGraphCoder.subtract(left, right) }
    public static func * (left: SGVector, right: SGScalar) -> SGVector { ShaderGraphCoder.multiply(left, right) }
    public static func / (left: SGVector, right: SGScalar) -> SGVector { ShaderGraphCoder.divide(left, right) }
    public static func % (left: SGVector, right: SGScalar) -> SGVector { ShaderGraphCoder.modulo(left, right) }
    public static func + (left: SGVector, right: Float) -> SGVector { ShaderGraphCoder.add(left, .float(right)) }
    public static func - (left: SGVector, right: Float) -> SGVector { ShaderGraphCoder.subtract(left, .float(right)) }
    public static func * (left: SGVector, right: Float) -> SGVector { ShaderGraphCoder.multiply(left, .float(right)) }
    public static func / (left: SGVector, right: Float) -> SGVector { ShaderGraphCoder.divide(left, .float(right)) }
    public static func % (left: SGVector, right: Float) -> SGVector { ShaderGraphCoder.modulo(left, .float(right)) }
    public static func + (left: SGScalar, right: SGVector) -> SGVector { ShaderGraphCoder.add(right, left) }
    public static func * (left: SGScalar, right: SGVector) -> SGVector { ShaderGraphCoder.multiply(right, left) }
    public static func + (left: Float, right: SGVector) -> SGVector { ShaderGraphCoder.add(right, .float(left)) }
    public static func * (left: Float, right: SGVector) -> SGVector { ShaderGraphCoder.multiply(right, .float(left)) }

    public var x: SGScalar { getSeparateOutput("outx") }
    public var y: SGScalar { getSeparateOutput("outy") }
    public var z: SGScalar { getSeparateOutput("outz") }
    public var w: SGScalar { getSeparateOutput("outw") }
    public var xy: SGVector { combine(values: [x, y], dataType: .vector2f) }
    public var xyz: SGVector { combine(values: [x, y, z], dataType: .vector3f) }
}

public class SGColor: SGSIMD {
    public static func + (left: SGColor, right: SGColor) -> SGColor { ShaderGraphCoder.add(left, right) }
    public static func - (left: SGColor, right: SGColor) -> SGColor { ShaderGraphCoder.subtract(left, right) }
    public static func * (left: SGColor, right: SGColor) -> SGColor { ShaderGraphCoder.multiply(left, right) }
    public static func / (left: SGColor, right: SGColor) -> SGColor { ShaderGraphCoder.divide(left, right) }
    public static func % (left: SGColor, right: SGColor) -> SGColor { ShaderGraphCoder.modulo(left, right) }
    public static func + (left: SGColor, right: SGScalar) -> SGColor { ShaderGraphCoder.add(left, right) }
    public static func - (left: SGColor, right: SGScalar) -> SGColor { ShaderGraphCoder.subtract(left, right) }
    public static func * (left: SGColor, right: SGScalar) -> SGColor { ShaderGraphCoder.multiply(left, right) }
    public static func / (left: SGColor, right: SGScalar) -> SGColor { ShaderGraphCoder.divide(left, right) }
    public static func % (left: SGColor, right: SGScalar) -> SGColor { ShaderGraphCoder.modulo(left, right) }
    public static func + (left: SGColor, right: Float) -> SGColor { ShaderGraphCoder.add(left, .float(right)) }
    public static func - (left: SGColor, right: Float) -> SGColor { ShaderGraphCoder.subtract(left, .float(right)) }
    public static func * (left: SGColor, right: Float) -> SGColor { ShaderGraphCoder.multiply(left, .float(right)) }
    public static func / (left: SGColor, right: Float) -> SGColor { ShaderGraphCoder.divide(left, .float(right)) }
    public static func % (left: SGColor, right: Float) -> SGColor { ShaderGraphCoder.modulo(left, .float(right)) }
    public static func + (left: SGScalar, right: SGColor) -> SGColor { ShaderGraphCoder.add(right, left) }
    public static func * (left: SGScalar, right: SGColor) -> SGColor { ShaderGraphCoder.multiply(right, left) }
    public static func + (left: Float, right: SGColor) -> SGColor { ShaderGraphCoder.add(right, .float(left)) }
    public static func * (left: Float, right: SGColor) -> SGColor { ShaderGraphCoder.multiply(right, .float(left)) }

    public var r: SGScalar { getSeparateOutput("outr") }
    public var g: SGScalar { getSeparateOutput("outg") }
    public var b: SGScalar { getSeparateOutput("outb") }
    public var a: SGScalar { getSeparateOutput("outa") }
    public var rgb: SGColor { combine(values: [r, g, b], dataType: .color3f) }
    public var bgr: SGColor { combine(values: [b, g, r], dataType: .color3f) }
}

public class SGString: SGValue {

}

public class SGAsset: SGValue {

}

public class SGTexture: SGAsset {

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
