import os
from pxr import Usd

class Node():
    def __init__(self, prim):
        self.name = prim.GetName()
        property_names = prim.GetPropertyNames()
        self.inputs = []
        self.outputs = []
        for pn in property_names:
            p = prim.GetAttribute(pn)
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
        self.type_name = t.type.typeName
        self.type_is_array = t.isArray
        self.default_value = p.Get() if p.HasValue() else None

    def __str__(self):
        return f'{self.name}: {self.type_name} = {self.default_value}'

def is_node(prim):
    path = str(prim.GetPath()).split('/')
    return len(path) == 2 and len(path[0]) == 0 and path[1].startswith('ND_')

def should_output_node(node: Node):
    if node.name.startswith('ND_Internal'):
        print(f'Skipping {node.name} because it is internal')
        return False
    if len(node.outputs) != 1:
        print(f'Skipping {node.name} because it has {len(node.outputs)} outputs')
        return False
    if node.outputs[0].type_is_array:
        print(f'Skipping {node.name} because its output is an array')
        return False
    return True

suffix_type_names = [
    "_color3",
    "_color4",
    "_integer2",
    "_integer3",
    "_integer4",
    "_vector2",
    "_vector3",
    "_vector4",
]

this_abs_path = os.path.abspath(__file__)
schemas_path = os.path.join(os.path.dirname(this_abs_path), 'schemas.usda')

stage = Usd.Stage.Open(schemas_path)
all_prims = [x for x in stage.Traverse()]  
nodes = [Node(x) for x in all_prims if is_node(x)]
print(f'Found {len(nodes)} nodes')
output_nodes = [x for x in nodes if should_output_node(x)]
print(f'Outputting {len(output_nodes)} nodes')

p = nodes[40]
print(p)
print("    Inputs:")
for i in p.inputs:
    print("       ", i)
print("    Outputs:")
for o in p.outputs:
    print("       ", o)
