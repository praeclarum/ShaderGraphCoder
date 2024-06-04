import os
import re
from typing import Dict, List, Optional, Tuple, Union
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
]

param_renames: Dict[str, str] = {
    "in": "in1",
    "default": "defaultValue",
}

node_renames: Dict[str, str] = {
    "in": "mixColor",
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

    def __str__(self):
        return f'{self.name} ({len(self.inputs)} inputs, {len(self.outputs)} outputs)'
    
class NodeProperty():
    def __init__(self, node: Node, property_name: str, p):
        self.property_name = property_name
        self.name = property_name.split(':')[-1]
        t = p.GetTypeName()
        self.usd_type_aliases = t.aliasesAsStrings
        self.usd_type_name = self.usd_type_aliases[0] if len(self.usd_type_aliases) > 0 else t.type.typeName
        self.type_is_array = t.isArray
        self.default_value = p.Get() if p.HasValue() else None

    def __str__(self):
        return f'{self.name}: {self.usd_type_name} = {self.default_value}'

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
    if node.outputs[0].usd_type_name == 'token':
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
    print("Unknown USD datatype:", usd_type)
    return f"SGDataType.{usd_type}"

def load_plist_strings(plist_path) -> Dict[str, str]:
    with open(plist_path, 'rb') as f:
        plist = plistlib.load(f)
    print(plist)
    return plist

class SwiftWriter():
    def __init__(self):
        self.lines = []
        self.current_line = ""
        self.write_header()

    def commit_current_line(self):
        if len(self.current_line) > 0:
            self.lines.append(self.current_line)
            self.current_line = ""

    def output_to_file(self, file_path: str):
        with open(file_path, 'w') as f:
            self.write_footer(f)
            for line in self.lines:
                f.write(line)
                f.write('\n')

    def write_header(self):
        self.write_line('// Autogenerated by opgen.py')
        self.write_line('import Foundation')
        self.write_line('')

    def write_footer(self, f):
        self.write_line('')

    def write_line(self, text: str):
        self.current_line += text
        self.commit_current_line()

    def write(self, text: str):
        self.current_line += text

class NodeOverloads():
    overloads: List[Tuple[Optional[str], Node]]
    is_src: bool
    def __init__(self, base_name: str, first_suffix_type_name: Optional[str], first_node: Node):
        self.base_name = base_name
        self.overloads = [(first_suffix_type_name, first_node)]
        self.is_src = len(first_node.inputs) == 0
    def add_overload(self, suffix_type_name: Optional[str], node: Node):
        self.overloads.append((suffix_type_name, node))

node_overloads: Dict[str, NodeOverloads] = {}

def add_node_to_overloads(node: Node):
    base_name, suffix_type_name = get_node_suffix_type_name(node)
    if base_name not in node_overloads:
        node_overloads[base_name] = NodeOverloads(base_name, suffix_type_name, node)
    else:
        node_overloads[base_name].add_overload(suffix_type_name, node)

def capitalize_first_letter(name: str) -> str:
    if name == "uv0":
        return "UV0"
    if name == "uv1":
        return "UV1"
    return name.capitalize()

def snake_to_camel(name: str) -> str:
    parts = name.split('_')
    return parts[0] + ''.join(capitalize_first_letter(x) for x in parts[1:])

def get_param_name(name: str) -> str:
    if name in param_renames:
        return param_renames[name]
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

def get_node_description(node: Node) -> str:
    if node.name in node_descriptions:
        description = node_descriptions[node.name].strip()
        if description.endswith(')'):
            leftp_index = description.rfind('(')
            if leftp_index != -1:
                return description[:leftp_index].strip()
    return ""

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
    if composite_type == "SGMatrix":
        return "SGMatrix"
    if composite_type == "SGColor":
        return "SGColor"
    if composite_type == "SGVector":
        return "SGVector"
    if composite_type == "SGScalar":
        return "SGScalar"
    if composite_type == "SGColorSGVector":
        return "SGSIMD"
    if composite_type == "SGVectorSGScalar" or \
       composite_type == "SGColorSGScalar" or \
       composite_type == "SGMatrixSGColorSGVectorSGScalar" or \
       composite_type == "SGColorSGVectorSGScalar":
        return "SGNumeric"
    if composite_type == "":
        return "SGValue"
    print("Warning: Could not determine base SG type for", composite_type)
    return "SGValue"

def write_node_overloads(overloads: NodeOverloads, w: SwiftWriter):
    swift_name = get_node_name(overloads.base_name)
    first_node = overloads.overloads[0][1]
    first_output = first_node.outputs[0]
    description = get_node_description(first_node)
    usd_param_type_is_shared = [True for _ in first_node.inputs]
    sgc_param_type_is_shared = [True for _ in first_node.inputs]
    sgc_output_type_is_shared = True
    usd_shared_param_type = [p.usd_type_name for p in first_node.inputs]
    sgc_shared_param_type = [usd_type_to_sgc_type(p.usd_type_name) for p in first_node.inputs]
    sgc_shared_output_type = usd_type_to_sgc_type(first_output.usd_type_name)
    num_default_inputs = 0
    param_names: List[str] = []
    for i, input in enumerate(first_node.inputs):
        if i == num_default_inputs and is_default_input_name(input.name):
            num_default_inputs += 1
        param_names.append(get_param_name(input.name))
    for suffix_type_name, node in overloads.overloads[1:]:
        for i, input in enumerate(node.inputs):
            if input.usd_type_name != usd_shared_param_type[i]:
                usd_param_type_is_shared[i] = False
            if usd_type_to_sgc_type(input.usd_type_name) != sgc_shared_param_type[i]:
                sgc_param_type_is_shared[i] = False
        if usd_type_to_sgc_type(node.outputs[0].usd_type_name) != usd_type_to_sgc_type(first_node.outputs[0].usd_type_name):
            sgc_output_type_is_shared = False
    num_unshared_usd_params = len([x for x in usd_param_type_is_shared if not x])
    if len(description) > 0:
        w.write_line(f'/// {description}')
    w.write(f'public func {swift_name}(')
    for i, input in enumerate(first_node.inputs):
        sgc_type_is_shared = sgc_param_type_is_shared[i]
        sgc_type = sgc_shared_param_type[i]
        if not sgc_type_is_shared:
            all_types = [usd_type_to_sgc_type(o[1].inputs[i].usd_type_name) for o in overloads.overloads]
            sgc_type = get_base_sg_type(all_types)
        name = f"_ {param_names[i]}" if i < num_default_inputs else param_names[i]
        w.write(f'{name}: {sgc_type}')
        if i < len(first_node.inputs) - 1:
            w.write(', ')
    sgc_output_types = [usd_type_to_sgc_type(o[1].outputs[0].usd_type_name) for o in overloads.overloads]
    sgc_output_type = get_base_sg_type(sgc_output_types)
    w.write_line(f') -> {sgc_output_type} {{')
    for i, input in enumerate(first_node.inputs):
        if not usd_param_type_is_shared[i]:
            continue
        sgc_datatype = usd_type_to_sgc_datatype(input.usd_type_name)
        w.write_line(f'    guard {param_names[i]}.dataType == {sgc_datatype} else {{')
        w.write_line(f'        return {sgc_output_type}Error("Invalid {swift_name} input. Expected {input.name} data type to be {sgc_datatype}, but got \({param_names[i]}.dataType).")')
        w.write_line(f'    }}')
    w.write_line(f'    let inputs: [SGNode.Input] = [')
    for i, input in enumerate(first_node.inputs):
        w.write_line(f'        .init(name: "{input.name}", connection: {param_names[i]}),')
    w.write_line(f'    ]')
    for suffix_type_name, node in overloads.overloads:
        sgc_output_type = usd_type_to_sgc_type(node.outputs[0].usd_type_name)
        conds: List[str] = []
        for i, input in enumerate(node.inputs):
            if usd_param_type_is_shared[i]:
                continue
            name = param_names[i]
            conds.append(f'{name}.dataType == {usd_type_to_sgc_datatype(input.usd_type_name)}')
        if len(conds) == 0:
            indent = ""
            if len(overloads.overloads) > 1:
                print(f'Warning: {swift_name} has multiple overloads but none of the inputs have unique types')
        else:
            cond = " && ".join(conds)
            w.write_line(f'    if {cond} {{')
            indent = "    "
        w.write_line(f'    {indent}return {sgc_output_type}(source: .nodeOutput(SGNode(')
        w.write_line(f'        {indent}nodeType: "{node.name}",')
        w.write_line(f'        {indent}inputs: inputs,')
        w.write_line(f'        {indent}outputs: [.init(dataType: {usd_type_to_sgc_datatype(node.outputs[0].usd_type_name)})])))')
        if len(conds) > 0:
            w.write_line(f'    }}')
    if num_unshared_usd_params > 0:
        w.write_line(f'    return {sgc_output_type}Error("Unsupported input data types for {swift_name}")')
    w.write_line('}')

def write_src_node(overloads: NodeOverloads, w: SwiftWriter):
    swift_name = get_node_name(overloads.base_name)
    first_node = overloads.overloads[0][1]
    first_output = first_node.outputs[0]
    description = get_node_description(first_node)
    sgc_output_type = usd_type_to_sgc_type(first_output.usd_type_name)
    if len(description) > 0:
        w.write_line(f'    /// {description}')
    w.write_line(f'    var {swift_name}: {sgc_output_type} {{')
    sgc_output_type = usd_type_to_sgc_type(first_output.usd_type_name)
    indent = "    "
    w.write_line(f'    {indent}return {sgc_output_type}(source: .nodeOutput(SGNode(')
    w.write_line(f'        {indent}nodeType: "{first_node.name}",')
    w.write_line(f'        {indent}inputs: [],')
    w.write_line(f'        {indent}outputs: [.init(dataType: {usd_type_to_sgc_datatype(first_output.usd_type_name)})])))')
    w.write_line('    }')

tools_path = os.path.dirname(os.path.abspath(__file__))
schemas_path = os.path.join(tools_path, 'schemas.usda')
plist_path = os.path.join(tools_path, 'schemas.plist') 
src_path = os.path.abspath(os.path.join(tools_path, '..', 'Sources', 'ShaderGraphCoder'))
node_descriptions = load_plist_strings(plist_path)

ops_out_path = os.path.join(src_path, 'Operations.g.swift')
srcs_out_path = os.path.join(src_path, 'Sources.g.swift')

stage = Usd.Stage.Open(schemas_path)
all_prims = [x for x in stage.Traverse()]  

test_prim = [x for x in all_prims if x.GetName() == 'ND_time_float'][0]
dir(test_prim.GetAttribute('inputs:in').GetTypeName())
test_prim.GetAttribute('inputs:in').GetTypeName().aliasesAsStrings

prop_is_supported(test_prim.GetAttribute('inputs:fps'))

nodes = [Node(x) for x in all_prims if is_node(x) and prim_is_supported(x)]
print(f'Found {len(nodes)} nodes')
output_nodes = [x for x in nodes if should_output_node(x)]
output_nodes = sorted(output_nodes, key=lambda x: x.name)
print(f'Outputting {len(output_nodes)} nodes')
for node in output_nodes:
    add_node_to_overloads(node)
print(f'Outputting {len(node_overloads)} overloads')
src_nodes: List[NodeOverloads] = []
op_nodes: List[NodeOverloads] = []
for base_name, no in node_overloads.items():
    if no.is_src:
        src_nodes.append(no)
    else:
        op_nodes.append(no)
print(f'Outputting {len(op_nodes)} operations')
print(f'Outputting {len(src_nodes)} sources')

ops_writer = SwiftWriter()
for node in op_nodes:
    write_node_overloads(node, ops_writer)
ops_writer.output_to_file(ops_out_path)

srcs_writer = SwiftWriter()
srcs_writer.write_line('public extension SGValue {')
for node in src_nodes:
    write_src_node(node, srcs_writer)
srcs_writer.write_line('}')
srcs_writer.output_to_file(srcs_out_path)
