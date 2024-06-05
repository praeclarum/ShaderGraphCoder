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
    static func color3fParameter(name: String, defaultValue: SIMD3<Float>, colorSpace: SGColorSpace = .textureSRGB) -> SGColor {
        SGColor(source: .parameter(name: name, defaultValue: .color3f(defaultValue, colorSpace: colorSpace)))
    }
    static func color4f(_ x: Float, _ y: Float, _ z: Float, _ w: Float, colorSpace: SGColorSpace = .textureSRGB) -> SGColor {
        SGColor(source: .constant(.color4f([x, y, z, w], colorSpace: colorSpace)))
    }
    static func color4fParameter(name: String, defaultValue: SIMD4<Float>, colorSpace: SGColorSpace = .textureSRGB) -> SGColor {
        SGColor(source: .parameter(name: name, defaultValue: .color4f(defaultValue, colorSpace: colorSpace)))
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
    static func texture1DParameter(name: String) -> SGTexture1D {
        SGTexture1D(source: .parameter(name: name, defaultValue: .emptyTexture1D))
    }
    static func texture2DParameter(name: String) -> SGTexture2D {
        SGTexture2D(source: .parameter(name: name, defaultValue: .emptyTexture2D))
    }
    static func texture3DParameter(name: String) -> SGTexture3D {
        SGTexture3D(source: .parameter(name: name, defaultValue: .emptyTexture3D))
    }
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

    static var modelNormal: SGVector {
        normal(space: .model)
    }
    static var modelPosition: SGVector {
        position(space: .model)
    }
    static var objectNormal: SGVector {
        normal(space: .object)
    }
    static var objectPosition: SGVector {
        position(space: .object)
    }
    static var worldCameraPosition: SGVector {
        cameraPosition(space: .world)
    }
    static var worldPosition: SGVector {
        position(space: .world)
    }
    static var worldNormal: SGVector {
        normal(space: .world)
    }
}
