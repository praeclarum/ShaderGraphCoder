//
//  Operations.swift
//  ShaderGraphCoder
//
//  Created by Frank A. Krueger on 2/10/24.
//

import Foundation

public func clamp<T>(_ in1: T, min: Float, max: Float) -> T where T: SGNumeric {
    clamp<T>(in1, min: SGValue.float(min), max: SGValue.float(max))
}

func combine<T>(values: [SGScalar], dataType: SGDataType) -> T where T: SGSIMD {
    var errors: [String] = []
    var n = 3
    let nodeSuffix = getNodeSuffixForDataType(dataType)
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
    case .vector2h:
        n = 2
    case .vector3h:
        n = 3
    case .vector4h:
        n = 4
    case .vector2i:
        n = 2
    case .vector3i:
        n = 3
    case .vector4i:
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
        nodeType: "ND_combine\(n)_\(nodeSuffix)",
        inputs: inputs,
        outputs: outputs)
    return T(source: .nodeOutput(sep))
}

public func ifEqual(_ value1: SGValue, _ value2: SGValue, trueResult: Float, falseResult: Float) -> SGScalar {
    ifEqual(value1, value2, trueResult: SGValue.float(trueResult), falseResult: SGValue.float(falseResult))
}

public func ifGreaterOrEqual(_ value1: SGScalar, _ value2: SGScalar, trueResult: Float, falseResult: Float) -> SGScalar {
    ifGreaterOrEqual(value1, value2, trueResult: SGValue.float(trueResult), falseResult: SGValue.float(falseResult))
}

public func ifGreater(_ value1: SGScalar, _ value2: SGScalar, trueResult: Float, falseResult: Float) -> SGScalar {
    ifGreater(value1, value2, trueResult: SGValue.float(trueResult), falseResult: SGValue.float(falseResult))
}

public func ifLess<T>(_ value1: SGScalar, _ value2: SGScalar, trueResult: T, falseResult: T) -> T where T: SGNumeric {
    ifGreaterOrEqual(value2, value1, trueResult: trueResult, falseResult: falseResult)
}

public func ifLess(_ value1: SGScalar, _ value2: SGScalar, trueResult: Float, falseResult: Float) -> SGScalar {
    ifGreaterOrEqual(value2, value1, trueResult: SGValue.float(trueResult), falseResult: SGValue.float(falseResult))
}

public func ifLessOrEqual<T>(_ value1: SGScalar, _ value2: SGScalar, trueResult: T, falseResult: T) -> T where T: SGNumeric {
    ifGreater(value2, value1, trueResult: trueResult, falseResult: falseResult)
}

public func ifLessOrEqual(_ value1: SGScalar, _ value2: SGScalar, trueResult: Float, falseResult: Float) -> SGScalar {
    ifGreater(value2, value1, trueResult: SGValue.float(trueResult), falseResult: SGValue.float(falseResult))
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

// MARK: - Private

private func getNodeSuffixForDataType(_ dataType: SGDataType) -> String {
    switch dataType {
    case .asset:
        return "asset"
    case .bool:
        return "bool"
    case .color3f:
        return "color3"
    case .color4f:
        return "color4"
    case .error:
        return "error"
    case .float:
        return "float"
    case .half:
        return "half"
    case .int:
        return "int"
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
    case .vector2i:
        return "int2"
    case .vector3i:
        return "int3"
    case .vector4i:
        return "int4"
    case .matrix2d:
        return "matrix22"
    case .matrix3d:
        return "matrix33"
    case .matrix4d:
        return "matrix44"
    case .string:
        return "string"
    case .token:
        return "token"
    }
}
