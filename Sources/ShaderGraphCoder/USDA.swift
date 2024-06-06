//
//  USDA.swift
//  ShaderGraphCoder
//
//  Created by Frank A. Krueger on 2/10/24.
//

import Foundation

public extension SGNode {
    var usdaName: String { "Node\(id)" }
}

public extension SGDataType {
    var usda: String {
        switch self {
        case .surface:
            return "token"
        case .geometryModifier:
            return "token"
        default:
            return self.rawValue
        }
    }
}

public extension SIMD2<Float> {
    var usda: String {
        return "(\(self.x), \(self.y))"
    }
}

public extension SIMD3<Float> {
    var usda: String {
        return "(\(self.x), \(self.y), \(self.z))"
    }
}

public extension SIMD4<Float> {
    var usda: String {
        return "(\(self.x), \(self.y), \(self.z), \(self.w))"
    }
}

public extension SGConstantValue {
    var usda: String {
        switch self {
        case .bool(let v):
            return v ? "1" : "0"
        case .color3f(let v, colorSpace: .some(let cs)):
            return "\(v.usda) (colorSpace = \"\(cs.rawValue)\")"
        case .color4f(let v, colorSpace: .some(let cs)):
            return "\(v.usda) (colorSpace = \"\(cs.rawValue)\")"
        case .color3f(let v, colorSpace: .none):
            return v.usda
        case .color4f(let v, colorSpace: .none):
            return v.usda
        case .emptyTexture1D:
            return "\"\""
        case .emptyTexture2D:
            return "\"\""
        case .emptyTexture3D:
            return "\"\""
        case .float(let v):
            return "\(v)"
        case .half(let v):
            return "\(v)"
        case .int(let v):
            return "\(v)"
        case .string(let v):
            return "\"\(v)\""
        case .token(let v):
            return "\"\(v)\""
        case .vector2f(let v):
            return v.usda
        case .vector3f(let v):
            return v.usda
        case .vector4f(let v):
            return v.usda
        case .vector2h(let v):
            return "(\(v.x), \(v.y))"
        case .vector3h(let v):
            return "(\(v.x), \(v.y), \(v.z))"
        case .vector4h(let v):
            return "(\(v.x), \(v.y), \(v.z), \(v.w))"
        case .vector2i(let v):
            return "(\(v.x), \(v.y))"
        case .vector3i(let v):
            return "(\(v.x), \(v.y), \(v.z))"
        case .vector4i(let v):
            return "(\(v.x), \(v.y), \(v.z), \(v.w))"
        case .matrix2d(let v):
            return "(\(v.columns.0.usda), \(v.columns.1.usda))"
        case .matrix3d(let v):
            return "(\(v.columns.0.usda), \(v.columns.1.usda), \(v.columns.2.usda))"
        case .matrix4d(let v):
            return "(\(v.columns.0.usda), \(v.columns.1.usda), \(v.columns.2.usda), \(v.columns.3.usda))"
        }
    }
}

public extension SGValueSource {
    func getUSDAReference(materialName: String) -> String {
        switch self {
        case .constant(let ivalue):
            return ivalue.usda
        case .nodeOutput(let inode, let inodeOut):
            return "</Root/\(materialName)/\(inode.usdaName).outputs:\(inodeOut)>"
        case .parameter(name: let name, defaultValue: _):
            return "</Root/\(materialName).inputs:\(name)>"
        case .error(let error, _):
            return "\"\(error)\""
        }
    }
}

public func getUSDA(materialName: String, surface: SGSurface?, geometryModifier: SGGeometryModifier?) -> (String, [String]) {
    var lines: [String] = []
    func line(_ text: String) {
        lines.append(text)
    }
    line("#usda 1.0")
    line("(")
    line("    defaultPrim = \"Root\"")
    line("    metersPerUnit = 1")
    line("    upAxis = \"Y\"")
    line(")")
    line("")
    line("def Xform \"Root\"")
    line("{")
    line("    reorder nameChildren = [\"\(materialName)\"]")
    line("    def Material \"\(materialName)\"")
    line("    {")
    
    let outputNodes = [surface, geometryModifier].compactMap { $0 }
    let parameters = collectParameters(nodes: outputNodes)
    let errors = collectErrors(nodes: outputNodes)
    for p in parameters {
        let (name, defaultValue) = p
        line("        \(defaultValue.dataType.usda) inputs:\(name) = \(defaultValue.usda)")
    }
    
    if let s = surface {
        let v = s.getOutputValue(name: "out").getUSDAReference(materialName: materialName)
        line("        token outputs:mtlx:surface.connect = \(v)")
    }
    else {
        line("        token outputs:mtlx:surface")
    }
    if let g = geometryModifier {
        let v = g.getOutputValue(name: "out").getUSDAReference(materialName: materialName)
        line("        token outputs:realitykit:vertex.connect = \(v)")
    }
    else {
        line("        token outputs:realitykit:vertex")
    }
    
    var nodesToWrite: [SGNode] = outputNodes
    var nodesWritten: Set<SGNode> = []
    while nodesToWrite.count > 0 {
        let node = nodesToWrite[0]
        nodesToWrite.remove(at: 0)
        nodesWritten.insert(node)
        line("")
        line("        def Shader \"\(node.usdaName)\"")
        line("        {")
        line("            uniform token info:id = \"\(node.nodeType)\"")
        for i in node.inputs {
            var decl = "\(i.dataType.usda) inputs:\(i.name)"
            if let c = i.value?.source {
                if case .nodeOutput = c {
                    decl += ".connect"
                }
                else if case .parameter = c {
                    decl += ".connect"
                }
            }
            if let value = i.value?.source.getUSDAReference(materialName: materialName) {
                line("            \(decl) = \(value)")
            }
            else {
                line("            \(decl)")
            }
        }
        for o in node.outputs {
            let decl = "\(o.dataType.usda) outputs:\(o.name)"
            line("            \(decl)")
        }
        line("        }")
        for i in node.inputs {
            if case .nodeOutput(let inode, _) = i.value?.source {
                if !(nodesWritten.contains(inode) || nodesToWrite.contains(inode)) {
                    nodesToWrite.append(inode)
                }
            }
        }
    }
    
    line("    }")
    line("}")
    
    return (lines.joined(separator: "\n"), errors)
}

public extension SGSurface {
    func usda(materialName: String) -> String {
        return getUSDA(materialName: materialName, surface: self, geometryModifier: nil).0
    }
}

public extension SGGeometryModifier {
    func usda(materialName: String) -> String {
        return getUSDA(materialName: materialName, surface: nil, geometryModifier: self).0
    }
}
