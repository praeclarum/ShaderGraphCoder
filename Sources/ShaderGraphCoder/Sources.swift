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
    static var customAttribute: SGVector {
        SGVector(source: SGValueSource.nodeOutput(SGNode.customAttribute, "customAttribute"))
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
    static var modelNormal: SGVector {
        SGVector(source: SGValueSource.nodeOutput(SGNode.modelNormal))
    }
    static var modelPosition: SGVector {
        SGVector(source: SGValueSource.nodeOutput(SGNode.modelPosition))
    }
    static var objectNormal: SGVector {
        SGVector(source: SGValueSource.nodeOutput(SGNode.objectNormal))
    }
    static var objectPosition: SGVector {
        SGVector(source: SGValueSource.nodeOutput(SGNode.objectPosition))
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
    static var time: SGScalar {
        SGScalar(source: SGValueSource.nodeOutput(SGNode.time))
    }
    static func uv(index: Int) -> SGVector {
        SGVector(source: SGValueSource.nodeOutput(SGNode.uv(index: index)))
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
    static var worldCameraPosition: SGVector {
        SGVector(source: SGValueSource.nodeOutput(SGNode.worldCameraPosition))
    }
    static var worldPosition: SGVector {
        SGVector(source: SGValueSource.nodeOutput(SGNode.worldPosition))
    }
    static var worldNormal: SGVector {
        SGVector(source: SGValueSource.nodeOutput(SGNode.worldNormal))
    }
}

public extension SGNode {
    static let customAttribute = SGNode(nodeType: "ND_realitykit_surface_custom_attribute", inputs: [], outputs: [.init(name: "customAttribute", dataType: .vector4f)])
    static let modelNormal = SGNode(nodeType: "ND_normal_vector3", inputs: [.init(name: "space", connection: .string("model"))], outputs: [.init(name: "out", dataType: .vector3f)])
    static let modelPosition = SGNode(nodeType: "ND_position_vector3", inputs: [.init(name: "space", connection: .string("model"))], outputs: [.init(name: "out", dataType: .vector3f)])
    static let objectNormal = SGNode(nodeType: "ND_normal_vector3", inputs: [.init(name: "space", connection: .string("object"))], outputs: [.init(name: "out", dataType: .vector3f)])
    static let objectPosition = SGNode(nodeType: "ND_position_vector3", inputs: [.init(name: "space", connection: .string("object"))], outputs: [.init(name: "out", dataType: .vector3f)])
    static let time = SGNode(nodeType: "ND_time_float", inputs: [], outputs: [.init(name: "out", dataType: .float)])
    static let worldCameraPosition = SGNode(nodeType: "ND_realitykit_cameraposition_vector3", inputs: [], outputs: [.init(name: "out", dataType: .vector3f)])
    static let worldPosition = SGNode(nodeType: "ND_position_vector3", inputs: [.init(name: "space", connection: .string("world"))], outputs: [.init(name: "out", dataType: .vector3f)])
    static let worldNormal = SGNode(nodeType: "ND_normal_vector3", inputs: [.init(name: "space", connection: .string("world"))], outputs: [.init(name: "out", dataType: .vector3f)])
    static func uv(index: Int) -> SGNode {
        SGNode(nodeType: "ND_texcoord_vector2", inputs: [.init(name: "index", connection: .int(index))], outputs: [.init(name: "out", dataType: .vector2f)])
    }
}
