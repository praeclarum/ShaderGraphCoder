//
//  Operations.swift
//  ShaderGraphCoder
//
//  Created by Frank A. Krueger on 2/10/24.
//

import Foundation


public func color3f(_ r: SGScalar, _ g: SGScalar, _ b: SGScalar) -> SGColor {
    return combine(values: [r, g, b], dataType: .color3f)
}

public func color4f(_ r: SGScalar, _ g: SGScalar, _ b: SGScalar, _ a: SGScalar) -> SGColor {
    return combine(values: [r, g, b, a], dataType: .color4f)
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

public func clamp(_ x: SGScalar, low: Float, high: Float) -> SGScalar {
    clamp<SGScalar>(x, low: SGValue.float(low), high: SGValue.float(high))
}

@available(*, deprecated, message: "Min and max were renamed to low and high")
public func clamp(_ x: SGScalar, min: Float, max: Float) -> SGScalar {
    clamp<SGScalar>(x, low: min, high: max)
}

public func ifGreaterOrEqual<T, U>(_ value1: T, _ value2: T, trueResult: U, falseResult: U) -> U where T: SGNumeric, U: SGValue {
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

public func ifGreaterOrEqual<T>(_ value1: T, _ value2: T, trueResult: Float, falseResult: Float) -> SGScalar where T: SGNumeric {
    ifGreaterOrEqual(value1, value2, trueResult: .float(trueResult), falseResult: .float(falseResult))
}

public func ifLess<T, U>(_ value1: T, _ value2: T, trueResult: U, falseResult: U) -> U where T: SGNumeric, U: SGValue {
    ifGreaterOrEqual(value2, value1, trueResult: trueResult, falseResult: falseResult)
}

public func ifLess<T>(_ value1: T, _ value2: T, trueResult: Float, falseResult: Float) -> SGScalar where T: SGNumeric {
    ifGreaterOrEqual(value2, value1, trueResult: .float(trueResult), falseResult: .float(falseResult))
}

public func map(_ x: SGScalar, x1: SGScalar, x2: SGScalar, y1: SGScalar, y2: SGScalar) -> SGScalar {
    let dx = x2 - x1
    let dy = y2 - y1
    let m = dy / dx
    return m*(x - x1) + y1
}

public func map(_ x: SGScalar, x1: SGScalar, x2: SGScalar, y1: SGColor, y2: SGColor) -> SGColor {
    let dx = x2 - x1
    let dy = y2 - y1
    let m = dy / dx
    return m*(x - x1) + y1
}

public func map(_ x: SGScalar, x1: SGScalar, x2: SGScalar, y1: SGVector, y2: SGVector) -> SGVector {
    let dx = x2 - x1
    let dy = y2 - y1
    let m = dy / dx
    return m*(x - x1) + y1
}

public func pow<T>(_ x: T, _ y: Float) -> T where T: SGNumeric {
    pow<T>(x, SGValue.float(y))
}

public func safePow<T>(_ x: T, _ y: Float) -> T where T: SGNumeric {
    safePow<T>(x, SGValue.float(y))
}

public func vector2f(_ x: SGScalar, _ y: SGScalar) -> SGVector {
    return combine(values: [x, y], dataType: .vector2f)
}

public func vector3f(_ x: SGScalar, _ y: SGScalar, _ z: SGScalar) -> SGVector {
    return combine(values: [x, y, z], dataType: .vector3f)
}

public func vector4f(_ x: SGScalar, _ y: SGScalar, _ z: SGScalar, _ w: SGScalar) -> SGVector {
    return combine(values: [x, y, z, w], dataType: .vector4f)
}

// MARK: - Private

private func getNodeSuffixForDataType(_ dataType: SGDataType) -> String {
    switch dataType {
    case .color3f:
        return "color3"
    case .color4f:
        return "color4"
    case .float:
        return "float"
    case .half:
        return "half"
    case .vector2f:
        return "vector2"
    case .vector3f:
        return "vector3"
    case .vector4f:
        return "vector4"
    case .vector2h:
        return "half2"
    case .vector3h:
        return "half3"
    case .vector4h:
        return "half4"
    case .matrix2d:
        return "matrix22"
    case .matrix3d:
        return "matrix33"
    case .matrix4d:
        return "matrix44"
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

func binop<T>(_ nodeType: String, left: SGNumeric, right: SGNumeric) -> T where T: SGNumeric {
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
        case .half:
            nt += "half"
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
        case .vector2h:
            if r.dataType.isScalar {
                nt += "half2FA"
            }
            else {
                nt += "half2"
            }
        case .vector3h:
            if r.dataType.isScalar {
                nt += "half3FA"
            }
            else {
                nt += "half3"
            }
        case .vector4h:
            if r.dataType.isScalar {
                nt += "half4FA"
            }
            else {
                nt += "half4"
            }
        case .matrix2d:
            if r.dataType.isScalar {
                nt += "matrix22FA"
            }
            else {
                nt += "matrix22"
            }
        case .matrix3d:
            if r.dataType.isScalar {
                nt += "matrix33FA"
            }
            else {
                nt += "matrix33"
            }
        case .matrix4d:
            if r.dataType.isScalar {
                nt += "matrix44FA"
            }
            else {
                nt += "matrix44"
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
private func inferBinaryOutputType(left: SGDataType, right: SGDataType) -> SGDataType {
    if left.isScalar {
        return right
    }
    return left
}
func unop<T>(_ nodeType: String, x: SGNumeric, dataType: SGDataType? = nil) -> T where T: SGNumeric {
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
        case .half:
            nt += "half"
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
        case .vector2h:
            nt += "half2"
        case .vector3h:
            nt += "half3"
        case .vector4h:
            nt += "half4"
        case .matrix2d:
            nt += "matrix22"
        case .matrix3d:
            nt += "matrix33"
        case .matrix4d:
            nt += "matrix44"
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
