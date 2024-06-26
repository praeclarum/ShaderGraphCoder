//
//  ShaderGraphCoder.swift
//  ShaderGraphCoder
//
//  Created by Frank A. Krueger on 2/10/24.
//

import Foundation
import RealityKit

infix operator ^^ : LogicalDisjunctionPrecedence

public class SGValue {
    public let source: SGValueSource
    public var dataType: SGDataType { source.dataType }
    public var node: SGNode? { source.node }
    public required init(source: SGValueSource) {
        self.source = source
    }
    public static func && (left: SGValue, right: SGValue) -> SGValue { ShaderGraphCoder.logicalAnd(left, right) }
    public static func || (left: SGValue, right: SGValue) -> SGValue { ShaderGraphCoder.logicalOr(left, right) }
    public static func ^^ (left: SGValue, right: SGValue) -> SGValue { ShaderGraphCoder.logicalXor(left, right) }
    public static prefix func ! (left: SGValue) -> SGValue { ShaderGraphCoder.logicalNot(left) }
}

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

public class SGMatrix: SGNumeric {
    public static func + (left: SGMatrix, right: SGMatrix) -> SGMatrix { ShaderGraphCoder.add(left, right) }
    public static func - (left: SGMatrix, right: SGMatrix) -> SGMatrix { ShaderGraphCoder.subtract(left, right) }
    public static func * (left: SGMatrix, right: SGMatrix) -> SGMatrix { ShaderGraphCoder.multiply(left, right) }
    public static func / (left: SGMatrix, right: SGMatrix) -> SGMatrix { ShaderGraphCoder.divide(left, right) }
    public static func + (left: SGMatrix, right: SGScalar) -> SGMatrix { ShaderGraphCoder.add(left, right) }
    public static func - (left: SGMatrix, right: SGScalar) -> SGMatrix { ShaderGraphCoder.subtract(left, right) }
    public static func * (left: SGMatrix, right: SGScalar) -> SGMatrix { ShaderGraphCoder.multiply(left, right) }
    public static func / (left: SGMatrix, right: SGScalar) -> SGMatrix { ShaderGraphCoder.divide(left, right) }
    public static func + (left: SGMatrix, right: Float) -> SGMatrix { ShaderGraphCoder.add(left, .float(right)) }
    public static func - (left: SGMatrix, right: Float) -> SGMatrix { ShaderGraphCoder.subtract(left, .float(right)) }
    public static func * (left: SGMatrix, right: Float) -> SGMatrix { ShaderGraphCoder.multiply(left, .float(right)) }
    public static func / (left: SGMatrix, right: Float) -> SGMatrix { ShaderGraphCoder.divide(left, .float(right)) }
    public static func + (left: SGScalar, right: SGMatrix) -> SGMatrix { ShaderGraphCoder.add(right, left) }
    public static func * (left: SGScalar, right: SGMatrix) -> SGMatrix { ShaderGraphCoder.multiply(right, left) }
    public static func + (left: Float, right: SGMatrix) -> SGMatrix { ShaderGraphCoder.add(right, .float(left)) }
    public static func * (left: Float, right: SGMatrix) -> SGMatrix { ShaderGraphCoder.multiply(right, .float(left)) }
}

public class SGSIMD: SGNumeric {
    private var separate: SGNode? = nil
    func getSeparateOutput(_ name: String) -> SGScalar {
        if let esep = separate {
            return SGScalar(source: .nodeOutput(esep, name))
        }
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
            return SGScalar(source: .error("Cannot separate \(self.dataType.usda)", values: [self]))
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
            outputs: outputs)
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

public class SGToken: SGValue {

}

public class SGAsset: SGValue {

}

public class SGTexture: SGAsset {
    public func sampleColor3f(texcoord: SGVector? = nil, uWrapMode: SGSamplerAddressMode = SGSamplerAddressMode.clampToEdge, vWrapMode: SGSamplerAddressMode = SGSamplerAddressMode.clampToEdge, borderColor: SGSamplerBorderColor = SGSamplerBorderColor.transparentBlack, magFilter: SGSamplerMinMagFilter = SGSamplerMinMagFilter.linear, minFilter: SGSamplerMinMagFilter = SGSamplerMinMagFilter.linear, mipFilter: SGSamplerMipFilter = SGSamplerMipFilter.linear, maxAnisotropy: SGScalar? = nil, maxLodClamp: SGScalar? = nil, minLodClamp: SGScalar? = nil, bias: SGScalar? = nil, dynamicMinLodClamp: SGScalar? = nil, offset: SGVector? = nil) -> SGColor {
        ShaderGraphCoder.sample(file: self, uWrapMode: uWrapMode, vWrapMode: vWrapMode, borderColor: borderColor, magFilter: magFilter, minFilter: minFilter, mipFilter: mipFilter, maxAnisotropy: maxAnisotropy, maxLodClamp: maxLodClamp, minLodClamp: minLodClamp, defaultValue: .black, texcoord: texcoord, bias: bias, dynamicMinLodClamp: dynamicMinLodClamp, offset: offset)
    }
    public func sampleColor4f(texcoord: SGVector? = nil, uWrapMode: SGSamplerAddressMode = SGSamplerAddressMode.clampToEdge, vWrapMode: SGSamplerAddressMode = SGSamplerAddressMode.clampToEdge, borderColor: SGSamplerBorderColor = SGSamplerBorderColor.transparentBlack, magFilter: SGSamplerMinMagFilter = SGSamplerMinMagFilter.linear, minFilter: SGSamplerMinMagFilter = SGSamplerMinMagFilter.linear, mipFilter: SGSamplerMipFilter = SGSamplerMipFilter.linear, maxAnisotropy: SGScalar? = nil, maxLodClamp: SGScalar? = nil, minLodClamp: SGScalar? = nil, bias: SGScalar? = nil, dynamicMinLodClamp: SGScalar? = nil, offset: SGVector? = nil) -> SGColor {
        ShaderGraphCoder.sample(file: self, uWrapMode: uWrapMode, vWrapMode: vWrapMode, borderColor: borderColor, magFilter: magFilter, minFilter: minFilter, mipFilter: mipFilter, maxAnisotropy: maxAnisotropy, maxLodClamp: maxLodClamp, minLodClamp: minLodClamp, defaultValue: .transparentBlack, texcoord: texcoord, bias: bias, dynamicMinLodClamp: dynamicMinLodClamp, offset: offset)
    }
    public func sampleVector4f(texcoord: SGVector? = nil, uWrapMode: SGSamplerAddressMode = SGSamplerAddressMode.clampToEdge, vWrapMode: SGSamplerAddressMode = SGSamplerAddressMode.clampToEdge, borderColor: SGSamplerBorderColor = SGSamplerBorderColor.transparentBlack, magFilter: SGSamplerMinMagFilter = SGSamplerMinMagFilter.linear, minFilter: SGSamplerMinMagFilter = SGSamplerMinMagFilter.linear, mipFilter: SGSamplerMipFilter = SGSamplerMipFilter.linear, maxAnisotropy: SGScalar? = nil, maxLodClamp: SGScalar? = nil, minLodClamp: SGScalar? = nil, bias: SGScalar? = nil, dynamicMinLodClamp: SGScalar? = nil, offset: SGVector? = nil) -> SGVector {
        ShaderGraphCoder.sample(file: self, uWrapMode: uWrapMode, vWrapMode: vWrapMode, borderColor: borderColor, magFilter: magFilter, minFilter: minFilter, mipFilter: mipFilter, maxAnisotropy: maxAnisotropy, maxLodClamp: maxLodClamp, minLodClamp: minLodClamp, defaultValue: .vector4fZero, texcoord: texcoord, bias: bias, dynamicMinLodClamp: dynamicMinLodClamp, offset: offset)
    }
}
