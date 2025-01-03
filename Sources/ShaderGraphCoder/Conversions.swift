import Foundation

extension SGValue {
    convenience init(nodeType: String, in connection: SGValue, out: SGDataType) {
        self.init(source: .nodeOutput(SGNode(nodeType: nodeType, inputs: [.init(name: "in", connection: connection)], outputs: [.init(dataType: out)])))
    }
}

// valid color related conversions:
// grep -REoh 'ND_\w+' /Applications/Xcode.app/Contents/SystemFrameworks/ShaderGraph.framework/Versions/A/Resources | sort -u | grep convert | grep color
public extension SGColor {
    convenience init(_ value: SGVector) {
        switch value.dataType {
        case .vector3f: self.init(nodeType: "ND_convert_vector3_color3", in: value, out: .color3f)
        case .vector3h: self.init(nodeType: "ND_convert_half3_color3", in: value, out: .color3f)
        case .vector4f: self.init(nodeType: "ND_convert_vector4_color4", in: value, out: .color4f)
        case .vector4h: self.init(nodeType: "ND_convert_half4_color4", in: value, out: .color4f)
        default:
            self.init(source: .error("Unsupported input data types. Expected input value to be vector{3f,3h,4f,4h}", values: [value]))
        }
    }

    convenience init(color3From value: SGValue) {
        switch value.dataType {
        case .color4f: self.init(nodeType: "ND_convert_color4_color3", in: value, out: .color3f)
        case .float: self.init(nodeType: "ND_convert_float_color3", in: value, out: .color3f)
        case .half: self.init(nodeType: "ND_convert_half_color3", in: value, out: .color3f)
        case .vector3f, .vector3h: self.init(SGVector(source: value.source))
        default:
            self.init(source: .error("Unsupported input data types. Expected input value to be {color3f,float,half,vector3f,vector3h}", values: [value]))
        }
    }

    convenience init(color4From value: SGValue) {
        switch value.dataType {
        case .color3f: self.init(nodeType: "ND_convert_color3_color4", in: value, out: .color4f)
        case .float: self.init(nodeType: "ND_convert_float_color4", in: value, out: .color4f)
        case .half: self.init(nodeType: "ND_convert_half_color4", in: value, out: .color4f)
        case .vector4f, .vector4h: self.init(SGVector(source: value.source))
        default:
            self.init(source: .error("Unsupported input data types. Expected input value to be {color3f,float,half,vector4f,vector4h}", values: [value]))
        }
    }
}
