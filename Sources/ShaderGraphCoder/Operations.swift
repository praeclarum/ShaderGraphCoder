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

public func abs<T>(_ x: T) -> T where T: SGNumeric {
    unop("ND_absval_", x: x)
}

public func ceil<T>(_ x: T) -> T where T: SGNumeric {
    unop("ND_ceil_", x: x)
}

public func clamp<T>(_ x: T, min: T, max: T) -> T where T: SGNumeric {
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

public func clamp(_ x: SGScalar, min: Float, max: Float) -> SGScalar {
    clamp(x, min: SGValue.float(min), max: SGValue.float(max))
}

public func cos<T>(_ x: T) -> T where T: SGNumeric {
    unop("ND_cos_", x: x)
}

public func cross(_ x: SGVector, _ y: SGVector) -> SGVector {
    binop("ND_crossproduct_", left: x, right: y)
}

public func dot(_ x: SGVector, _ y: SGVector) -> SGScalar {
    binop("ND_dotproduct_", left: x, right: y)
}

public func floor<T>(_ x: T) -> T where T: SGNumeric {
    unop("ND_floor_", x: x)
}

public func fract<T>(_ x: T) -> T where T: SGNumeric {
    unop("ND_realitykit_fractional_", x: x)
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

public func length<T>(_ x: T) -> SGScalar where T: SGSIMD {
    let node = SGNode(
        nodeType: "ND_magnitude_" + getNodeSuffixForDataType(x.dataType),
        inputs: [.init(name: "in", connection: x)],
        outputs: [.init(dataType: .float)])
    return SGScalar(source: .nodeOutput(node))
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

public func max<T>(_ x: T, _ y: T) -> T where T: SGNumeric {
    binop("ND_max_", left: x, right: y)
}

public func min<T>(_ x: T, _ y: T) -> T where T: SGNumeric {
    binop("ND_min_", left: x, right: y)
}

public func mix<T, U>(_ x: T, _ y: T, t: U) -> T where T: SGNumeric, U: SGNumeric {
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

public func normalize(_ x: SGVector) -> SGVector {
    unop("ND_normalize_", x: x)
}

public func oneMinus<T>(_ x: T) -> T where T: SGNumeric {
    unop("ND_realitykit_oneminus_", x: x)
}

public func pow<T>(_ x: T, _ y: SGNumeric) -> T where T: SGNumeric {
    binop("ND_power_", left: x, right: y)
}

public func pow<T>(_ x: T, _ y: Float) -> T where T: SGNumeric {
    binop("ND_power_", left: x, right: .float(y))
}

public func round<T>(_ x: T) -> T where T: SGNumeric {
    unop("ND_round_", x: x)
}

public func safePow<T>(_ x: T, _ y: T) -> T where T: SGNumeric {
    binop("ND_safepower_", left: x, right: y)
}

public func safePow<T>(_ x: T, _ y: Float) -> T where T: SGNumeric {
    binop("ND_safepower_", left: x, right: .float(y))
}

public func sign<T>(_ x: T) -> T where T: SGNumeric {
    unop("ND_sign_", x: x)
}

public func sin<T>(_ x: T) -> T where T: SGNumeric {
    unop("ND_sin_", x: x)
}

public func sqrt<T>(_ x: T) -> T where T: SGNumeric {
    unop("ND_sqrt_", x: x)
}

public func tan<T>(_ x: T) -> T where T: SGNumeric {
    unop("ND_tan_", x: x)
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
