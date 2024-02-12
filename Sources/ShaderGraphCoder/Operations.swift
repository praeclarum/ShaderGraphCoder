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

public func combine<T>(values: [SGScalar], dataType: SGDataType) -> T where T: SGSIMD {
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
    SGNumeric.unary("ND_absval_", x: x)
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
    SGNumeric.unary("ND_cos_", x: x)
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

public func pow<T>(_ x: T, _ y: SGNumeric) -> T where T: SGNumeric {
    SGNumeric.binary("ND_power_", left: x, right: y)
}

public func pow<T>(_ x: T, _ y: Float) -> T where T: SGNumeric {
    SGNumeric.binary("ND_power_", left: x, right: .float(y))
}

public func sin<T>(_ x: T) -> T where T: SGNumeric {
    SGNumeric.unary("ND_sin_", x: x)
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
