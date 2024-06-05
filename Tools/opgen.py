import os
import re
from typing import Dict, List, Optional, Set, Tuple, Union
from pxr import Usd
import plistlib

manual_node_prefixes = [
    'ND_combine',
    'ND_realitykit_combine',
    'ND_constant_',
    'ND_swizzle_',
    'ND_convert_',

    'ND_surfacematerial',
    'ND_realitykit_geometrymodifier_vertexshader',
    'ND_realitykit_pbr_surfaceshader',
    'ND_realitykit_unlit_surfaceshader',
    'ND_add_surfaceshader',
    'ND_dot_surfaceshader',
    'ND_mix_surfaceshader',
    'ND_multiply_surfaceshader',
    'ND_add_displacementshader',
    'ND_dot_displacementshader',
    'ND_mix_displacementshader',
    'ND_multiply_displacementshader',
    'ND_volumematerial',
    'ND_add_volumeshader',
    'ND_dot_volumeshader',
    'ND_mix_volumeshader',
    'ND_multiply_volumeshader',
    'ND_dot_lightshader',
    'ND_UsdPreviewSurface_surfaceshader',

    'ND_RealityKitTexture',
    'ND_Usd',

    'ND_dot_',
]

param_renames: Dict[str, str] = {
    "in": "in1",
    "default": "defaultValue",
}

node_renames: Dict[str, str] = {
    "absval": "abs",
    "dotproduct": "dot",
    "cameraposition": "cameraPosition",
    "crossproduct": "cross",
    "fractional": "fract",
    "ifequal": "ifEqual",
    "ifgreater": "ifGreater",
    "ifgreatereq": "ifGreaterOrEqual",
    "in": "mixColor",
    "magnitude": "length",
    "oneminus": "oneMinus",
    "power": "pow",
    "safepower": "safePow",
    "switch": "switchValue",
}

def prop_is_supported(prop):
    cd = prop.GetCustomData()
    if cd is not None and "realitykit" in cd:
        rk = cd["realitykit"]
        if "unsupported" in rk:
            u = rk["unsupported"]
            if u is not None:
                return not u
    return True

def prim_is_supported(prim):
    cd = prim.GetCustomData()
    if cd is not None and "realitykit" in cd:
        rk = cd["realitykit"]
        if "availability" in rk:
            a = rk["availability"]
            if a is not None and a == "deprecated":
                return False
    return True

class Node():
    name: str
    inputs: List['NodeProperty']
    outputs: List['NodeProperty']
    def __init__(self, prim):
        self.name = str(prim.GetName())
        property_names = prim.GetPropertyNames()
        self.inputs = []
        self.outputs = []
        for pn in property_names:
            p = prim.GetAttribute(pn)
            if not prop_is_supported(p):
                continue
            if pn.startswith('inputs:'):
                self.inputs.append(NodeProperty(self, pn, p))
            if pn.startswith('outputs:'):
                self.outputs.append(NodeProperty(self, pn, p))
        if self.name in node_descriptions:
            self.description = node_descriptions[self.name].strip()
            if self.description.endswith(')'):
                leftp_index = self.description.rfind('(')
                if leftp_index != -1:
                    self.description = self.description[:leftp_index].strip()
        else:
            self.description = ""

    def __str__(self):
        return f'{self.name} ({len(self.inputs)} inputs, {len(self.outputs)} outputs)'
    
    def resolve_enums(self):
        for i in self.inputs:
            i.resolve_enums()
        for o in self.outputs:
            o.resolve_enums()
    
class NodeProperty():
    def __init__(self, node: Node, property_name: str, p):
        self.node = node
        self.property_name = property_name
        self.name = property_name.split(':')[-1]
        t = p.GetTypeName()
        self.usd_type_aliases = t.aliasesAsStrings
        self.usd_type = self.usd_type_aliases[0] if len(self.usd_type_aliases) > 0 else t.type.typeName
        self.type_is_array = t.isArray
        self.default_value = p.Get() if p.HasValue() else None
        metadata = p.GetAllMetadata()
        self.is_enum = False
        self.enum_members = []
        if self.usd_type == "string" and "allowedTokens" in metadata:
            self.enum_members = list(metadata["allowedTokens"])
            if len(self.enum_members) > 0:
                self.is_enum = True
        if "connectability" in metadata and metadata["connectability"] == "interfaceOnly":
            self.interface_only = True
        else:
            self.interface_only = False
        if "displayName" in metadata:
            self.display_name = str(metadata["displayName"])
        else:
            self.display_name = self.name

    def __str__(self):
        return f'{self.name}: {self.usd_type} = {self.default_value}'
    
    def resolve_enums(self):
        if self.is_enum:
            self.enum = get_enum(self.enum_members, self.node)
            self.usd_type = self.enum.gen_usd_type

class EnumType():
    def __init__(self, id: int, structural_type_id: str, members: List[str], node: Node):
        self.id = id
        self.structural_type_id = structural_type_id
        self.members = sorted(members)
        self.gen_usd_type = f'enum{id}'
        self.gen_sgc_type = f'SGEnum{id}_' + '_'.join(self.members)
        if structural_type_id in enum_sgc_types:
            self.gen_sgc_type = enum_sgc_types[structural_type_id]
        else:
            print(f'Warning: No SGC type for enum \"{structural_type_id}\"')
        self.first_node_name = node.name
        # print(f'{self.first_node_name} created enum {self.gen_usd_type} with members {members}')

    def __str__(self):
        return self.type_id

def get_enum_structural_type_id(members: List[str]) -> str:
    sorted_members = sorted(members)
    return '|'.join(sorted_members)

enums_by_structural_type_id: Dict[str, EnumType] = {}
enums_by_gen_usd_type: Dict[str, EnumType] = {}

def get_enum(members: List[str], node: Node) -> EnumType:
    structural_type_id = get_enum_structural_type_id(members)
    if structural_type_id in enums_by_structural_type_id:
        return enums_by_structural_type_id[structural_type_id]
    enum_id = len(enums_by_structural_type_id)
    enum = EnumType(enum_id, structural_type_id, members, node)
    enums_by_structural_type_id[structural_type_id] = enum
    enums_by_gen_usd_type[enum.gen_usd_type] = enum
    return enum

enum_sgc_types: Dict[str, str] = {
    "box|gaussian": "SGBlurFilterType",
    "clamp|constant|mirror|periodic": "SGAddressMode",
    "closest|cubic|linear": "SGFilterType",
    "model|object|tangent|world": "SGSpace",
    "model|object|unspecified|world": "SGTransformSpace",
    "object|tangent": "SGNormalSpace",
}

def is_node(prim):
    path = str(prim.GetPath()).split('/')
    return len(path) == 2 and len(path[0]) == 0 and path[1].startswith('ND_')

def should_output_node(node: Node):
    if node.name.startswith('ND_Internal'):
        # print(f'Skipping {node.name} because it is internal')
        return False
    if len(node.outputs) != 1:
        # print(f'Skipping {node.name} because it has {len(node.outputs)} outputs')
        return False
    for i in node.inputs:
        if i.type_is_array:
            # print(f'Skipping {node.name} because it has an array input')
            return False
    if node.outputs[0].type_is_array:
        # print(f'Skipping {node.name} because its output is an array')
        return False
    if node.outputs[0].usd_type == 'token':
        # print(f'Skipping {node.name} because its output is a token')
        return False
    for prefix in manual_node_prefixes:
        if node.name.startswith(prefix):
            # print(f'Skipping {node.name} because it is a manual node')
            return False
    return True

default_input_name_re = re.compile(r'^in(\d+)?$')
def is_default_input_name(name: str) -> bool:
    return default_input_name_re.match(name) is not None

suffix_type_names: List[str] = [
    "_boolean",
    "_color3",
    "_color3B",
    "_color3FA",
    "_color3I",
    "_color4",
    "_color4B",
    "_color4FA",
    "_color4I",
    "_filename",
    "_float",
    "_floatB",
    "_floatI",
    "_half",
    "_half2",
    "_half2B",
    "_half2FA",
    "_half2I",
    "_half3",
    "_half3B",
    "_half3FA",
    "_half3I",
    "_half4",
    "_half4B",
    "_half4FA",
    "_half4I",
    "_halfB",
    "_halfI",
    "_integer",
    "_integer2",
    "_integer3",
    "_integer4",
    "_matrix22",
    "_matrix22FA",
    "_matrix33",
    "_matrix33FA",
    "_matrix44",
    "_matrix44FA",
    "_string",
    "_vector2",
    "_vector2B",
    "_vector2FA",
    "_vector2I",
    "_vector3",
    "_vector3B",
    "_vector3FA",
    "_vector3I",
    "_vector4",
    "_vector4B",
    "_vector4FA",
    "_vector4I",
]

def get_node_suffix_type_name(node: Node) -> Tuple[str, Optional[str]]:
    for suffix in suffix_type_names:
        if node.name.endswith(suffix):
            base_name = node.name[:-len(suffix)]
            return base_name, suffix
    return node.name, None

def usd_type_to_sgc_type(usd_type: str) -> str:
    if usd_type == 'bool':
        return 'SGValue'
    if usd_type == 'color3f':
        return 'SGColor'
    if usd_type == 'color4f':
        return 'SGColor'
    if usd_type == 'float':
        return 'SGScalar'
    if usd_type == 'matrix2d':
        return 'SGMatrix'
    if usd_type == 'matrix3d':
        return 'SGMatrix'
    if usd_type == 'matrix4d':
        return 'SGMatrix'
    if usd_type == 'float2':
        return 'SGVector'
    if usd_type == 'half2':
        return 'SGVector'
    if usd_type == 'int2':
        return 'SGVector'
    if usd_type == 'float3':
        return 'SGVector'
    if usd_type == 'half3':
        return 'SGVector'
    if usd_type == 'int3':
        return 'SGVector'
    if usd_type == 'float4':
        return 'SGVector'
    if usd_type == 'half4':
        return 'SGVector'
    if usd_type == 'int4':
        return 'SGVector'
    if usd_type == 'int':
        return 'SGScalar'
    if usd_type == 'half':
        return 'SGScalar'
    if usd_type == 'asset':
        return 'SGTexture'
    if usd_type == 'string':
        return 'SGString'
    if usd_type == 'token':
        return 'SGString'
    if usd_type in enums_by_gen_usd_type:
        return enums_by_gen_usd_type[usd_type].gen_sgc_type
    print("Unknown USD type:", usd_type)
    return usd_type

def usd_type_to_sgc_datatype(usd_type: str) -> str:
    if usd_type == 'bool':
        return 'SGDataType.bool'
    if usd_type == 'color3f':
        return 'SGDataType.color3f'
    if usd_type == 'color4f':
        return 'SGDataType.color4f'
    if usd_type == 'float':
        return 'SGDataType.float'
    if usd_type == 'matrix2d':
        return 'SGDataType.matrix2d'
    if usd_type == 'matrix3d':
        return 'SGDataType.matrix3d'
    if usd_type == 'matrix4d':
        return 'SGDataType.matrix4d'
    if usd_type == 'float2':
        return 'SGDataType.vector2f'
    if usd_type == 'half2':
        return 'SGDataType.vector2h'
    if usd_type == 'int2':
        return 'SGDataType.vector2i'
    if usd_type == 'float3':
        return 'SGDataType.vector3f'
    if usd_type == 'half3':
        return 'SGDataType.vector3h'
    if usd_type == 'int3':
        return 'SGDataType.vector3i'
    if usd_type == 'float4':
        return 'SGDataType.vector4f'
    if usd_type == 'half4':
        return 'SGDataType.vector4h'
    if usd_type == 'int4':
        return 'SGDataType.vector4i'
    if usd_type == 'int':
        return 'SGDataType.int'
    if usd_type == 'half':
        return 'SGDataType.half'
    if usd_type == 'asset':
        return 'SGDataType.asset'
    if usd_type == 'string':
        return 'SGDataType.string'
    if usd_type == 'token':
        return 'SGDataType.string'
    if usd_type in enums_by_gen_usd_type:
        return f"SGDataType.string"
    print("Unknown USD datatype:", usd_type)
    return f"SGDataType.{usd_type}"

def usd_type_to_const_ctor(usd_type):
    return usd_type_to_sgc_datatype(usd_type).replace('SGDataType.', '.')

def usd_type_to_primitive_type(usd_type: str) -> str:
    if usd_type == 'bool':
        return 'Bool'
    if usd_type == 'color3f':
        return 'SIMD3<Float>'
    if usd_type == 'color4f':
        return 'SIMD4<Float>'
    if usd_type == 'float':
        return 'Float'
    if usd_type == 'matrix2d':
        return 'SIMD2x2<Float>'
    if usd_type == 'matrix3d':
        return 'SIMD3x3<Float>'
    if usd_type == 'matrix4d':
        return 'SIMD4x4<Float>'
    if usd_type == 'float2':
        return 'SIMD2<Float>'
    if usd_type == 'half2':
        return 'SIMD2<Float16>'
    if usd_type == 'int2':
        return 'SIMD2<Int32>'
    if usd_type == 'float3':
        return 'SIMD3<Float>'
    if usd_type == 'half3':
        return 'SIMD3<Float16>'
    if usd_type == 'int3':
        return 'SIMD3<Int32>'
    if usd_type == 'float4':
        return 'SIMD4<Float>'
    if usd_type == 'half4':
        return 'SIMD4<Float16>'
    if usd_type == 'int4':
        return 'SIMD4<Int32>'
    if usd_type == 'int':
        return 'Int'
    if usd_type == 'half':
        return 'Float16'
    if usd_type == 'asset':
        return 'SGTexture'
    if usd_type == 'string':
        return 'String'
    if usd_type == 'token':
        return 'String'
    if usd_type in enums_by_gen_usd_type:
        return enums_by_gen_usd_type[usd_type].gen_sgc_type
    print("Unknown USD primitive type:", usd_type)
    return f"Any"

def load_plist_strings(plist_path) -> Dict[str, str]:
    with open(plist_path, 'rb') as f:
        plist = plistlib.load(f)
    return plist

class SwiftWriter():
    def __init__(self):
        self.lines = []
        self.current_line = ""
        self.needs_indent = True
        self.indent_level = 0
        self.write_header()

    def commit_current_line(self):
        if len(self.current_line) > 0:
            self.lines.append(self.current_line)
            self.current_line = ""
            self.needs_indent = True

    def output_to_file(self, file_path: str):
        with open(file_path, 'w') as f:
            self.write_footer(f)
            for line in self.lines:
                f.write(line)
                f.write('\n')

    def write_header(self):
        self.write_line('// Autogenerated by opgen.py')
        self.write_line('import Foundation')
        self.write_line('import simd')
        self.write_line('')

    def write_footer(self, f):
        self.write_line('')

    def write_line(self, text: str):
        self.write(text)
        self.commit_current_line()

    def write(self, text: str):
        if self.needs_indent:
            self.current_line += '    ' * self.indent_level
            self.needs_indent = False
        self.current_line += text

    def indent(self):
        self.indent_level += 1

    def unindent(self):
        self.indent_level -= 1

class NodeOverloads():
    overloads: List[Tuple[Optional[str], Node]]
    def __init__(self, base_name: str, first_suffix_type_name: Optional[str], first_node: Node):
        self.base_name = base_name
        self.swift_name = get_node_name(self.base_name)
        self.overloads = [(first_suffix_type_name, first_node)]
    def add_overload(self, suffix_type_name: Optional[str], node: Node):
        self.overloads.append((suffix_type_name, node))
    def first_node(self) -> Node:
        return self.overloads[0][1]
    def all_inputs_shared(self) -> bool:
        first_inputs = self.first_node().inputs
        for _, node in self.overloads[1:]:
            for i, input in enumerate(node.inputs):
                if input.usd_type != first_inputs[i].usd_type:
                    return False
        return True
    def is_src(self) -> bool:
        if len(self.overloads) != 1:
            return False
        if len(self.first_node().inputs) == 0:
            return True
        interface_only = find_interface_only_params(self)
        prims = find_primitive_params(self, interface_only)
        return all(prims)

node_overloads: Dict[str, NodeOverloads] = {}

def add_node_to_overloads(node: Node):
    base_name, suffix_type_name = get_node_suffix_type_name(node)
    if base_name not in node_overloads:
        node_overloads[base_name] = NodeOverloads(base_name, suffix_type_name, node)
    else:
        node_overloads[base_name].add_overload(suffix_type_name, node)

def snake_to_camel_part(part: str, cap: bool) -> str:
    if cap:
        if part == "uv0":
            return "UV0"
        if part == "uv1":
            return "UV1"
        part = part.capitalize()
    if part.endswith('2d'):
        part = part[:-2] + '2D'
    if part.endswith('3d'):
        part = part[:-2] + '3D'
    if part.endswith('4d'):
        part = part[:-2] + '4D'
    return part

def snake_to_camel(name: str) -> str:
    parts = name.split('_')
    ident = snake_to_camel_part(parts[0], False) + ''.join(snake_to_camel_part(x, True) for x in parts[1:])
    if ident == "repeat":
        ident = "repeated"
    return ident

def get_param_name(name: str, node: Node) -> str:
    if name in param_renames:
        return param_renames[name]
    if node.name.startswith("ND_ifequal_") or node.name.startswith("ND_ifgreater_") or node.name.startswith("ND_ifgreatereq_"):
        if name == "in1":
            return "trueResult"
        if name == "in2":
            return "falseResult"
    elif node.name.startswith("ND_clamp_"):
        if name == "low":
            return "min"
        if name == "high":
            return "max"
    name = snake_to_camel(name)
    return name

def get_node_name(name: str) -> str:
    if name.startswith('ND_realitykit_'):
        name = name[len('ND_realitykit_'):]
    elif name.startswith('ND_'):
        name = name[len('ND_'):]
    if name in node_renames:
        return node_renames[name]
    name = snake_to_camel(name)
    return name

def get_base_sg_type(sg_types: List[str]) -> str:
    def has_sg_type(sg_type: str) -> bool:
        return any(sg_type in x for x in sg_types)
    composite_type = ""
    if has_sg_type('SGMatrix'):
        composite_type += 'SGMatrix'
    if has_sg_type('SGColor'):
        composite_type += 'SGColor'
    if has_sg_type('SGVector'):
        composite_type += 'SGVector'
    if has_sg_type('SGScalar'):
        composite_type += 'SGScalar'
    if has_sg_type('SGString'):
        composite_type += 'SGString'
    if has_sg_type('SGValue'):
        composite_type += 'SGValue'
    if composite_type == "SGMatrix":
        return "SGMatrix"
    if composite_type == "SGColor":
        return "SGColor"
    if composite_type == "SGVector":
        return "SGVector"
    if composite_type == "SGScalar":
        return "SGScalar"
    if "SGValue" in composite_type:
        return "SGValue"
    if composite_type == "SGColorSGVector":
        return "SGSIMD"
    if composite_type == "SGVectorSGScalar" or \
       composite_type == "SGColorSGScalar" or \
       composite_type == "SGMatrixSGColorSGVectorSGScalar" or \
       composite_type == "SGColorSGVectorSGScalar":
        return "SGNumeric"
    print("Warning: Could not determine base SG type for", composite_type)
    return "SGValue"

def find_generic_params(overloads: NodeOverloads) -> Optional[Tuple[List[int], str]]:
    param_type_matches_output_type = [True for _ in overloads.first_node().inputs]
    sgc_output_types: Set[str] = set()
    for _, node in overloads.overloads:
        sgc_output_type = usd_type_to_sgc_type(node.outputs[0].usd_type)
        sgc_output_types.add(sgc_output_type)
        for i, input in enumerate(node.inputs):
            sgc_param_type = usd_type_to_sgc_type(input.usd_type)
            if sgc_param_type != sgc_output_type:
                param_type_matches_output_type[i] = False
    generic_indices = [i for i, x in enumerate(param_type_matches_output_type) if x]
    if len(generic_indices) == 0:
        return None
    if len(sgc_output_types) == 1:
        return None
    return generic_indices, get_base_sg_type(sgc_output_types)

def find_interface_only_params(overloads: NodeOverloads) -> List[bool]:
    interface_only = [i.usd_type != "asset" for i in overloads.first_node().inputs]
    for _, node in overloads.overloads:
        for i, input in enumerate(node.inputs):
            if not input.interface_only:
                interface_only[i] = False
    return interface_only

def find_primitive_params(overloads: NodeOverloads, interface_only_params: List[bool]) -> List[bool]:
    primitive = [True for i in overloads.first_node().inputs]
    for _, node in overloads.overloads:
        for i, input in enumerate(node.inputs):
            is_primitive = input.is_enum or interface_only_params[i]
            if not is_primitive:
                primitive[i] = False
    return primitive

def find_default_value_params(overloads: NodeOverloads) -> List[Optional[object]]:
    def default_ok(value, usd_type):
        if usd_type == "asset":
            return False
        elif usd_type in enums_by_gen_usd_type:
            return len(str(value)) > 0
        return value is not None
    default_values = [(i.default_value if default_ok(i.default_value, i.usd_type) else None) for i in overloads.first_node().inputs]
    default_value_valid = [v is not None for v in default_values]
    for _, node in overloads.overloads:
        for i, input in enumerate(node.inputs):
            if default_value_valid[i]:
                if input.default_value != default_values[i]:
                    default_value_valid[i] = False
    for i, valid in enumerate(default_value_valid):
        if not valid:
            default_values[i] = None
    return default_values

def write_enums(w: SwiftWriter):
    for enum in enums_by_gen_usd_type.values():
        w.write_line(f'public enum {enum.gen_sgc_type}: String, CaseIterable {{')
        for member in enum.members:
            swift_name = snake_to_camel(member)
            w.write_line(f'    case {swift_name} = "{member}"')
        w.write_line('}')
        w.write_line('')

def write_primitive_value(w: SwiftWriter, value, usd_type: str, sgc_type: str):
    if usd_type == 'bool':
        code = 'true' if value else 'false'
    elif usd_type == 'string':
        code = f'"{value}"'
    elif usd_type == 'token':
        code = f'"{value}"'
    elif usd_type == 'matrix2d':
        code = "simd_float2x2(columns: (" + str(value).replace('(', '[').replace(')', ']')[1:-1] + "))"
    elif usd_type == 'matrix3d':
        code = "simd_float3x3(columns: (" + str(value).replace('(', '[').replace(')', ']')[1:-1] + "))"
    elif usd_type == 'matrix4d':
        code = "simd_float4x4(columns: (" + str(value).replace('(', '[').replace(')', ']')[1:-1] + "))"
    elif usd_type in enums_by_gen_usd_type:
        code = f'{sgc_type}.{snake_to_camel(str(value))}'
    else:
        code = str(value).replace('(', '[').replace(')', ']')
    w.write(code)

def write_sgc_value(w: SwiftWriter, value, usd_type: str, sgc_type: str):
    ctor = usd_type_to_const_ctor(usd_type)
    w.write(f'{sgc_type}(source: .constant({ctor}(')
    write_primitive_value(w, value, usd_type, sgc_type)
    w.write(f')))')

def write_node_overloads(overloads: NodeOverloads, decl_public: bool, decl_static: bool, w: SwiftWriter):
    swift_name = overloads.swift_name
    first_node = overloads.overloads[0][1]
    first_output = first_node.outputs[0]
    num_inputs = len(first_node.inputs)
    generic_params = find_generic_params(overloads)
    interface_only_params = find_interface_only_params(overloads)
    primitive_params = find_primitive_params(overloads, interface_only_params)
    default_value_params = find_default_value_params(overloads)
    usd_param_type_is_shared = [True for _ in first_node.inputs]
    sgc_param_type_is_shared = [True for _ in first_node.inputs]
    usd_shared_param_type = [p.usd_type for p in first_node.inputs]
    sgc_shared_param_type = [usd_type_to_sgc_type(p.usd_type) for p in first_node.inputs]
    num_default_inputs = 0
    param_names: List[str] = []
    for i, input in enumerate(first_node.inputs):
        if i == num_default_inputs and is_default_input_name(input.name):
            num_default_inputs += 1
        param_names.append(get_param_name(input.name, first_node))
    for suffix_type_name, node in overloads.overloads[1:]:
        for i, input in enumerate(node.inputs):
            if input.usd_type != usd_shared_param_type[i]:
                usd_param_type_is_shared[i] = False
            if usd_type_to_sgc_type(input.usd_type) != sgc_shared_param_type[i]:
                sgc_param_type_is_shared[i] = False
    num_unshared_usd_params = len([x for x in usd_param_type_is_shared if not x])
    if len(first_node.description) > 0:
        w.write_line(f'/// {first_node.description}')
    write_func = num_inputs > 0
    if decl_public:
        w.write('public ')
    if decl_static:
        w.write('static ')
    if write_func:
        w.write(f'func {swift_name}')
        if generic_params is not None:
            w.write('<T>')
        w.write(f'(')
    else:
        w.write(f'var {swift_name}')
    for i, input in enumerate(first_node.inputs):
        sgc_type_is_shared = sgc_param_type_is_shared[i]
        sgc_type = sgc_shared_param_type[i]
        is_primitive = primitive_params[i]
        if not sgc_type_is_shared:
            all_types = [usd_type_to_sgc_type(o[1].inputs[i].usd_type) for o in overloads.overloads]
            sgc_type = get_base_sg_type(all_types)
        if is_primitive:
            sgc_type = usd_type_to_primitive_type(input.usd_type)
        elif generic_params is not None and i in generic_params[0]:
            sgc_type = 'T'
        name = f"_ {param_names[i]}" if i < num_default_inputs else param_names[i]
        w.write(f'{name}: {sgc_type}')
        if default_value_params[i] is not None:
            w.write(f' = ')
            if is_primitive:
                write_primitive_value(w, default_value_params[i], input.usd_type, sgc_type)
            else:
                write_sgc_value(w, default_value_params[i], input.usd_type, sgc_type)
        if i < len(first_node.inputs) - 1:
            w.write(', ')
    sgc_output_types = [usd_type_to_sgc_type(o[1].outputs[0].usd_type) for o in overloads.overloads]
    sgc_output_type = get_base_sg_type(sgc_output_types)
    if write_func:
        if generic_params is not None:
            sgc_output_type = 'T'
            w.write_line(f') -> T where T: {generic_params[1]} {{')
        else:
            w.write_line(f') -> {sgc_output_type} {{')
    else:
        w.write_line(f': {sgc_output_type} {{')
    for i, input in enumerate(first_node.inputs):
        if not usd_param_type_is_shared[i]:
            continue
        if first_node.inputs[i].is_enum:
            continue
        if interface_only_params[i]:
            continue
        sgc_datatype = usd_type_to_sgc_datatype(input.usd_type)
        w.write_line(f'    guard {param_names[i]}.dataType == {sgc_datatype} else {{')
        w.write_line(f'        return {sgc_output_type}(source: .error("Invalid {swift_name} input. Expected {input.name} data type to be {sgc_datatype}, but got \({param_names[i]}.dataType)."))')
        w.write_line(f'    }}')
    w.write_line(f'    let inputs: [SGNode.Input] = [')
    for i, input in enumerate(first_node.inputs):
        if input.is_enum:
            w.write_line(f'        .init(name: "{input.name}", connection: SGString(source: .constant(.string({param_names[i]}.rawValue)))),')
        elif interface_only_params[i]:
            sgct = usd_type_to_sgc_type(input.usd_type)
            ctor = usd_type_to_const_ctor(input.usd_type)
            w.write_line(f'        .init(name: "{input.name}", connection: {sgct}(source: .constant({ctor}({param_names[i]})))),')
        else:
            w.write_line(f'        .init(name: "{input.name}", connection: {param_names[i]}),')
    w.write_line(f'    ]')
    for suffix_type_name, node in overloads.overloads:
        conds: List[str] = []
        for i, input in enumerate(node.inputs):
            if usd_param_type_is_shared[i]:
                continue
            name = param_names[i]
            conds.append(f'{name}.dataType == {usd_type_to_sgc_datatype(input.usd_type)}')
        if len(conds) == 0:
            indent = ""
            if len(overloads.overloads) > 1:
                print(f'Warning: {swift_name} has multiple overloads but none of the inputs have unique types')
        else:
            cond = " && ".join(conds)
            w.write_line(f'    if {cond} {{')
            indent = "    "
        sgc_node_output_type = usd_type_to_sgc_type(node.outputs[0].usd_type)
        if generic_params is not None:
            sgc_node_output_type = 'T'
        w.write_line(f'    {indent}return {sgc_node_output_type}(source: .nodeOutput(SGNode(')
        w.write_line(f'        {indent}nodeType: "{node.name}",')
        w.write_line(f'        {indent}inputs: inputs,')
        w.write_line(f'        {indent}outputs: [.init(dataType: {usd_type_to_sgc_datatype(node.outputs[0].usd_type)})])))')
        if len(conds) > 0:
            w.write_line(f'    }}')
    if num_unshared_usd_params > 0:
        w.write_line(f'    return {sgc_output_type}(source: .error("Unsupported input data types for {swift_name}"))')
    w.write_line('}')


tools_path = os.path.dirname(os.path.abspath(__file__))
schemas_path = os.path.join(tools_path, 'schemas.usda')
plist_path = os.path.join(tools_path, 'schemas.plist') 
src_path = os.path.abspath(os.path.join(tools_path, '..', 'Sources', 'ShaderGraphCoder'))
node_descriptions = load_plist_strings(plist_path)

ops_out_path = os.path.join(src_path, 'Operations.g.swift')
srcs_out_path = os.path.join(src_path, 'Sources.g.swift')

stage = Usd.Stage.Open(schemas_path)
all_prims = [x for x in stage.Traverse()]  

test_prim = [x for x in all_prims if x.GetName() == 'ND_realitykit_image_half'][0]
dir(test_prim.GetAttribute('inputs:border_color').GetAllMetadata()["allowedTokens"])
list(test_prim.GetAttribute('inputs:border_color').GetAllMetadata()["allowedTokens"])

prop_is_supported(test_prim.GetAttribute('inputs:fps'))

nodes = [Node(x) for x in all_prims if is_node(x) and prim_is_supported(x)]
print(f'Found {len(nodes)} nodes')
output_nodes = [x for x in nodes if should_output_node(x)]
output_nodes = sorted(output_nodes, key=lambda x: x.name)
print(f'Outputting {len(output_nodes)} nodes')
for node in output_nodes:
    node.resolve_enums()
    add_node_to_overloads(node)
for key, no in list(node_overloads.items()):
    if len(no.overloads) > 1 and no.all_inputs_shared():
        del node_overloads[key]
        for suffix_type_name, node in no.overloads:
            new_base_name = key + suffix_type_name
            new_no = NodeOverloads(new_base_name, suffix_type_name, node)
            node_overloads[new_base_name] = new_no
print(f'Outputting {len(node_overloads)} overloads')
src_nodes: List[NodeOverloads] = []
op_nodes: List[NodeOverloads] = []
for no in (x[1] for x in node_overloads.items()):
    if no.is_src():
        src_nodes.append(no)
    else:
        op_nodes.append(no)
src_nodes = sorted(src_nodes, key=lambda x: x.swift_name)
op_nodes = sorted(op_nodes, key=lambda x: x.swift_name)
print(f'Outputting {len(op_nodes)} operations')
print(f'Outputting {len(src_nodes)} sources')

ops_writer = SwiftWriter()
write_enums(ops_writer)
for node in op_nodes:
    write_node_overloads(node, True, False, ops_writer)
ops_writer.output_to_file(ops_out_path)

srcs_writer = SwiftWriter()
srcs_writer.write_line('public extension SGValue {')
srcs_writer.indent()
for node in src_nodes:
    write_node_overloads(node, False, True, srcs_writer)
srcs_writer.unindent()
srcs_writer.write_line('}')
srcs_writer.output_to_file(srcs_out_path)

print('Done')
