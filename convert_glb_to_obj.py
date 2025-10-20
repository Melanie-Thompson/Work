import bpy
import sys
import os

# Find where "--" is in sys.argv to get actual script arguments
try:
    separator_index = sys.argv.index("--")
    script_args = sys.argv[separator_index + 1:]
except ValueError:
    print("Usage: blender --background --python convert_glb_to_obj.py -- <input.glb> <output.obj>")
    sys.exit(1)

if len(script_args) < 2:
    print("Usage: blender --background --python convert_glb_to_obj.py -- <input.glb> <output.obj>")
    sys.exit(1)

glb_file = os.path.abspath(script_args[0])
obj_file = os.path.abspath(script_args[1])

print(f"Converting {glb_file} to {obj_file}")

# Check if input file exists
if not os.path.exists(glb_file):
    print(f"Error: Input file {glb_file} does not exist")
    sys.exit(1)

# Clear the default scene
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

# Import GLB
print(f"Importing GLB file...")
bpy.ops.import_scene.gltf(filepath=glb_file)

# Export to OBJ
print(f"Exporting to OBJ...")
bpy.ops.wm.obj_export(filepath=obj_file, export_materials=True)

print(f"Successfully converted!")
