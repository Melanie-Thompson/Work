#!/usr/bin/env python3
"""Recenter OBJ file vertices to origin"""

import sys

def recenter_obj(input_file, output_file):
    vertices = []
    other_lines = []

    # Read the file and separate vertices from other content
    with open(input_file, 'r') as f:
        for line in f:
            if line.startswith('v '):
                parts = line.split()
                x, y, z = float(parts[1]), float(parts[2]), float(parts[3])
                vertices.append((x, y, z))
                other_lines.append(('v', len(vertices) - 1))
            else:
                other_lines.append(('other', line))

    # Calculate center
    min_x = min(v[0] for v in vertices)
    max_x = max(v[0] for v in vertices)
    min_y = min(v[1] for v in vertices)
    max_y = max(v[1] for v in vertices)
    min_z = min(v[2] for v in vertices)
    max_z = max(v[2] for v in vertices)

    center_x = (min_x + max_x) / 2
    center_y = (min_y + max_y) / 2
    center_z = (min_z + max_z) / 2

    print(f"Original center: ({center_x:.6f}, {center_y:.6f}, {center_z:.6f})")

    # Recenter vertices
    centered_vertices = []
    for x, y, z in vertices:
        centered_vertices.append((x - center_x, y - center_y, z - center_z))

    # Write the output file
    with open(output_file, 'w') as f:
        for line_type, data in other_lines:
            if line_type == 'v':
                v = centered_vertices[data]
                f.write(f"v {v[0]:.6f} {v[1]:.6f} {v[2]:.6f}\n")
            else:
                f.write(data)

    print(f"Recentered OBJ saved to {output_file}")

if __name__ == "__main__":
    input_file = "/Users/melaniethompson/three_dart_game/assets/models/machine.obj"
    output_file = "/Users/melaniethompson/three_dart_game/assets/models/machine.obj"
    recenter_obj(input_file, output_file)
