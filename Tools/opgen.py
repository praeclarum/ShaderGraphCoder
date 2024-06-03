import os
from pxr import Usd, Vt

class Node():
    def __init__(self, prim):
        self.prim = prim
        self.path = str(prim.GetPath())
        self.name = prim.GetName()
        property_names = prim.GetPropertyNames()
        self.inputs = []
        self.outputs = []
        for p in property_names:
            if p.startswith('inputs:'):
                self.inputs.append(NodeProperty(self, p))
            if p.startswith('outputs:'):
                self.outputs.append(NodeProperty(self, p))

    def get_property(self, property_name):
        return self.prim.GetAttribute(property_name)

    def __str__(self):
        return f'{self.name} ({self.type})'
    
class NodeProperty():
    def __init__(self, node: Node, property_name: str):
        self.property_name = property_name
        self.name = property_name.split(':')[-1]
        p = node.get_property(property_name)
        self.type_name = p.GetTypeName().type.typeName
        self.default_value = p.Get() if p.HasValue() else None

    def __str__(self):
        return f'{self.name}: {self.type_name} = {self.default_value}'

def is_node(prim):
    path = str(prim.GetPath()).split('/')
    return len(path) == 2 and len(path[0]) == 0 and path[1].startswith('ND_')

this_abs_path = os.path.abspath(__file__)
schemas_path = os.path.join(os.path.dirname(this_abs_path), 'schemas.usda')

stage = Usd.Stage.Open(schemas_path)
all_prims = [x for x in stage.Traverse()]  
nodes = [Node(x) for x in all_prims if is_node(x)]

p = nodes[40]
print("Inputs:")
for i in p.inputs:
    print("   ", i)
print("Outputs:")
for i in p.outputs:
    print("   ", i)
