//
//  Sources.swift
//  ShaderGraphCoder
//
//  Created by Frank A. Krueger on 2/10/24.
//

import Foundation
import RealityKit

public extension SGValue {
    static func color3f(_ value: SIMD3<Float>, colorSpace: SGColorSpace = .textureSRGB) -> SGColor {
        SGColor(source: .constant(.color3f(value, colorSpace: colorSpace)))
    }
    static func color3f(_ x: Float, _ y: Float, _ z: Float, colorSpace: SGColorSpace = .textureSRGB) -> SGColor {
        SGColor(source: .constant(.color3f([x, y, z], colorSpace: colorSpace)))
    }
    static func color3f(_ r: SGScalar, _ g: SGScalar, _ b: SGScalar) -> SGColor {
        return combine(values: [r, g, b], dataType: .color3f)
    }
    static func color3fParameter(name: String, defaultValue: SIMD3<Float>, colorSpace: SGColorSpace = .textureSRGB) -> SGColor {
        SGColor(source: .parameter(name: name, defaultValue: .color3f(defaultValue, colorSpace: colorSpace)))
    }
    static func color4f(_ x: Float, _ y: Float, _ z: Float, _ w: Float, colorSpace: SGColorSpace = .textureSRGB) -> SGColor {
        SGColor(source: .constant(.color4f([x, y, z, w], colorSpace: colorSpace)))
    }
    static func color4f(_ r: SGScalar, _ g: SGScalar, _ b: SGScalar, _ a: SGScalar) -> SGColor {
        return combine(values: [r, g, b, a], dataType: .color4f)
    }
    static func color4fParameter(name: String, defaultValue: SIMD4<Float>, colorSpace: SGColorSpace = .textureSRGB) -> SGColor {
        SGColor(source: .parameter(name: name, defaultValue: .color4f(defaultValue, colorSpace: colorSpace)))
    }
    static var identity2d: SGMatrix {
        .matrix2d(col0: [1, 0], col1: [0, 1])
    }
    static var identity3d: SGMatrix {
        .matrix3d(col0: [1, 0, 0], col1: [0, 1, 0], col2: [0, 0, 1])
    }
    static var identity4d: SGMatrix {
        .matrix4d(col0: [1, 0, 0, 0], col1: [0, 1, 0, 0], col2: [0, 0, 1, 0], col3: [0, 0, 0, 1])
    }
    static func int(_ value: Int) -> SGScalar {
        SGScalar(source: .constant(.int(value)))
    }
    static func float(_ value: Float) -> SGScalar {
        SGScalar(source: .constant(.float(value)))
    }
    static func floatParameter(name: String, defaultValue: Float) -> SGScalar {
        SGScalar(source: .parameter(name: name, defaultValue: .float(defaultValue)))
    }
    static func half(_ value: Float16) -> SGScalar {
        SGScalar(source: .constant(.half(value)))
    }
    static func halfParameter(name: String, defaultValue: Float16) -> SGScalar {
        SGScalar(source: .parameter(name: name, defaultValue: .half(defaultValue)))
    }

    static func matrix2d(_ value: simd_float2x2) -> SGMatrix {
        SGMatrix(source: .constant(.matrix2d(value)))
    }
    static func matrix2d(col0: SIMD2<Float>, col1: SIMD2<Float>) -> SGMatrix {
        SGMatrix(source: .constant(.matrix2d(simd_float2x2(columns: (col0, col1)))))
    }
    static func matrix2dParameter(name: String, defaultValue: simd_float2x2) -> SGMatrix {
        SGMatrix(source: .parameter(name: name, defaultValue: .matrix2d(defaultValue)))
    }

    static func matrix3d(_ value: simd_float3x3) -> SGMatrix {
        SGMatrix(source: .constant(.matrix3d(value)))
    }
    static func matrix3d(col0: SIMD3<Float>, col1: SIMD3<Float>, col2: SIMD3<Float>) -> SGMatrix {
        SGMatrix(source: .constant(.matrix3d(simd_float3x3(columns: (col0, col1, col2)))))
    }
    static func matrix3dParameter(name: String, defaultValue: simd_float3x3) -> SGMatrix {
        SGMatrix(source: .parameter(name: name, defaultValue: .matrix3d(defaultValue)))
    }

    static func matrix4d(_ value: simd_float4x4) -> SGMatrix {
        SGMatrix(source: .constant(.matrix4d(value)))
    }
    static func matrix4d(col0: SIMD4<Float>, col1: SIMD4<Float>, col2: SIMD4<Float>, col3: SIMD4<Float>) -> SGMatrix {
        SGMatrix(source: .constant(.matrix4d(simd_float4x4(columns: (col0, col1, col2, col3)))))
    }
    static func matrix4dParameter(name: String, defaultValue: simd_float4x4) -> SGMatrix {
        SGMatrix(source: .parameter(name: name, defaultValue: .matrix4d(defaultValue)))
    }

    static func string(_ value: String) -> SGString {
        SGString(source: .constant(.string(value)))
    }

    static func textureParameter(name: String) -> SGTexture {
        SGTexture(source: .parameter(name: name, defaultValue: .emptyTexture2D))
    }
    
    static let black = SGColor(source: .constant(.color3f([0, 0, 0])))
    static let white = SGColor(source: .constant(.color3f([1, 1, 1])))
    static let opaqueBlack = SGColor(source: .constant(.color4f([0, 0, 0, 1])))
    static let opaqueWhite = SGColor(source: .constant(.color4f([1, 1, 1, 1])))
    static let transparentBlack = SGColor(source: .constant(.color4f([0, 0, 0, 0])))
    
    static let vector2fZero = SGVector(source: .constant(.vector2f([0, 0])))
    static let vector3fZero = SGVector(source: .constant(.vector3f([0, 0, 0])))
    static let vector4fZero = SGVector(source: .constant(.vector4f([0, 0, 0, 0])))

    static func uv(index: Int) -> SGVector {
        texcoordVector2(index: index)
    }
    static var uv0: SGVector {
        SGValue.uv(index: 0)
    }
    static var uv1: SGVector {
        SGValue.uv(index: 1)
    }

    static func vector2f(_ value: SIMD2<Float>) -> SGVector {
        SGVector(source: .constant(.vector2f(value)))
    }
    static func vector2f(_ x: Float, _ y: Float) -> SGVector {
        SGVector(source: .constant(.vector2f([x, y])))
    }
    static func vector2fParameter(name: String, defaultValue: SIMD2<Float>) -> SGVector {
        SGVector(source: .parameter(name: name, defaultValue: .vector2f(defaultValue)))
    }
    static func vector3f(_ value: SIMD3<Float>) -> SGVector {
        SGVector(source: .constant(.vector3f(value)))
    }
    static func vector3f(_ x: Float, _ y: Float, _ z: Float) -> SGVector {
        SGVector(source: .constant(.vector3f([x, y, z])))
    }
    static func vector3fParameter(name: String, defaultValue: SIMD3<Float>) -> SGVector {
        SGVector(source: .parameter(name: name, defaultValue: .vector3f(defaultValue)))
    }
    static func vector4f(_ value: SIMD4<Float>) -> SGVector {
        SGVector(source: .constant(.vector4f(value)))
    }
    static func vector4f(_ x: Float, _ y: Float, _ z: Float, _ w: Float) -> SGVector {
        SGVector(source: .constant(.vector4f([x, y, z, w])))
    }
    static func vector4fParameter(name: String, defaultValue: SIMD4<Float>) -> SGVector {
        SGVector(source: .parameter(name: name, defaultValue: .vector4f(defaultValue)))
    }
    static func vector2f(_ x: SGScalar, _ y: SGScalar) -> SGVector {
        return combine(values: [x, y], dataType: .vector2f)
    }
    static func vector3f(_ x: SGScalar, _ y: SGScalar, _ z: SGScalar) -> SGVector {
        return combine(values: [x, y, z], dataType: .vector3f)
    }
    static func vector4f(_ x: SGScalar, _ y: SGScalar, _ z: SGScalar, _ w: SGScalar) -> SGVector {
        return combine(values: [x, y, z, w], dataType: .vector4f)
    }

    static func vector2h(_ value: SIMD2<Float16>) -> SGVector {
        SGVector(source: .constant(.vector2h(value)))
    }
    static func vector2h(_ x: Float16, _ y: Float16) -> SGVector {
        SGVector(source: .constant(.vector2h([x, y])))
    }
    static func vector2hParameter(name: String, defaultValue: SIMD2<Float16>) -> SGVector {
        SGVector(source: .parameter(name: name, defaultValue: .vector2h(defaultValue)))
    }
    static func vector3h(_ value: SIMD3<Float16>) -> SGVector {
        SGVector(source: .constant(.vector3h(value)))
    }
    static func vector3h(_ x: Float16, _ y: Float16, _ z: Float16) -> SGVector {
        SGVector(source: .constant(.vector3h([x, y, z])))
    }
    static func vector3hParameter(name: String, defaultValue: SIMD3<Float16>) -> SGVector {
        SGVector(source: .parameter(name: name, defaultValue: .vector3h(defaultValue)))
    }
    static func vector4h(_ value: SIMD4<Float16>) -> SGVector {
        SGVector(source: .constant(.vector4h(value)))
    }
    static func vector4h(_ x: Float16, _ y: Float16, _ z: Float16, _ w: Float16) -> SGVector {
        SGVector(source: .constant(.vector4h([x, y, z, w])))
    }
    static func vector4hParameter(name: String, defaultValue: SIMD4<Float16>) -> SGVector {
        SGVector(source: .parameter(name: name, defaultValue: .vector4h(defaultValue)))
    }
    static func vector2h(_ x: SGScalar, _ y: SGScalar) -> SGVector {
        return combine(values: [x, y], dataType: .vector2h)
    }
    static func vector3h(_ x: SGScalar, _ y: SGScalar, _ z: SGScalar) -> SGVector {
        return combine(values: [x, y, z], dataType: .vector3h)
    }
    static func vector4h(_ x: SGScalar, _ y: SGScalar, _ z: SGScalar, _ w: SGScalar) -> SGVector {
        return combine(values: [x, y, z, w], dataType: .vector4h)
    }

    static func vector2i(_ value: SIMD2<Int>) -> SGVector {
        SGVector(source: .constant(.vector2i(value)))
    }
    static func vector2i(_ x: Int, _ y: Int) -> SGVector {
        SGVector(source: .constant(.vector2i([x, y])))
    }
    static func vector2iParameter(name: String, defaultValue: SIMD2<Int>) -> SGVector {
        SGVector(source: .parameter(name: name, defaultValue: .vector2i(defaultValue)))
    }
    static func vector3i(_ value: SIMD3<Int>) -> SGVector {
        SGVector(source: .constant(.vector3i(value)))
    }
    static func vector3i(_ x: Int, _ y: Int, _ z: Int) -> SGVector {
        SGVector(source: .constant(.vector3i([x, y, z])))
    }
    static func vector3iParameter(name: String, defaultValue: SIMD3<Int>) -> SGVector {
        SGVector(source: .parameter(name: name, defaultValue: .vector3i(defaultValue)))
    }
    static func vector4i(_ value: SIMD4<Int>) -> SGVector {
        SGVector(source: .constant(.vector4i(value)))
    }
    static func vector4i(_ x: Int, _ y: Int, _ z: Int, _ w: Int) -> SGVector {
        SGVector(source: .constant(.vector4i([x, y, z, w])))
    }
    static func vector4iParameter(name: String, defaultValue: SIMD4<Int>) -> SGVector {
        SGVector(source: .parameter(name: name, defaultValue: .vector4i(defaultValue)))
    }
    static func vector2i(_ x: SGScalar, _ y: SGScalar) -> SGVector {
        return combine(values: [x, y], dataType: .vector2i)
    }
    static func vector3i(_ x: SGScalar, _ y: SGScalar, _ z: SGScalar) -> SGVector {
        return combine(values: [x, y, z], dataType: .vector3i)
    }
    static func vector4i(_ x: SGScalar, _ y: SGScalar, _ z: SGScalar, _ w: SGScalar) -> SGVector {
        return combine(values: [x, y, z, w], dataType: .vector4i)
    }

    static var modelBitangent0: SGVector {
        bitangent(space: .model, index: 0)
    }
    static var modelCameraPosition: SGVector {
        cameraPosition(space: .model)
    }
    static var modelNormal: SGVector {
        normal(space: .model)
    }
    static var modelPosition: SGVector {
        position(space: .model)
    }
    static var modelTangent0: SGVector {
        tangent(space: .model, index: 0)
    }
    static var modelUpDirection: SGVector {
        upDirection(space: .model)
    }
    static var modelViewDirection: SGVector {
        viewDirection(space: .model)
    }
    static var objectBitangent0: SGVector {
        bitangent(space: .object, index: 0)
    }
    static var objectCameraPosition: SGVector {
        cameraPosition(space: .object)
    }
    static var objectNormal: SGVector {
        normal(space: .object)
    }
    static var objectPosition: SGVector {
        position(space: .object)
    }
    static var objectTangent0: SGVector {
        tangent(space: .object, index: 0)
    }
    static var objectUpDirection: SGVector {
        upDirection(space: .object)
    }
    static var objectViewDirection: SGVector {
        viewDirection(space: .object)
    }
    static var worldCameraPosition: SGVector {
        cameraPosition(space: .world)
    }
    static var worldBitangent0: SGVector {
        bitangent(space: .world, index: 0)
    }
    static var worldNormal: SGVector {
        normal(space: .world)
    }
    static var worldPosition: SGVector {
        position(space: .world)
    }
    static var worldTangent0: SGVector {
        tangent(space: .world, index: 0)
    }
    static var worldUpDirection: SGVector {
        upDirection(space: .world)
    }
    static var worldViewDirection: SGVector {
        viewDirection(space: .world)
    }
}
