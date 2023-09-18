import { vec3, vec4 } from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import { gl } from '../globals';

class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;

  constructor(center: vec3) {
    super(); // Call the constructor of the super class. This is required.
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
  }

  create() {
    // Define the indices for each face of the cube. Each face is made up of two triangles.
    this.indices = new Uint32Array([
      0, 1, 2, 0, 2, 3, // Front face
      4, 5, 6, 4, 6, 7, // Back face
      8, 9, 10, 8, 10, 11, // Top face
      12, 13, 14, 12, 14, 15, // Bottom face
      16, 17, 18, 16, 18, 19, // Right face
      20, 21, 22, 20, 22, 23 // Left face
    ]);

  // Define normals for cube faces
this.normals = new Float32Array([
    // Front face normals
    0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 0,
    
    // Back face normals
    0, 0, -1, 0,
    0, 0, -1, 0,
    0, 0, -1, 0,
    0, 0, -1, 0,
  
    // Top face normals
    0, 1, 0, 0,
    0, 1, 0, 0,
    0, 1, 0, 0,
    0, 1, 0, 0,
  
    // Bottom face normals
    0, -1, 0, 0,
    0, -1, 0, 0,
    0, -1, 0, 0,
    0, -1, 0, 0,
  
    // Right face normals
    1, 0, 0, 0,
    1, 0, 0, 0,
    1, 0, 0, 0,
    1, 0, 0, 0,
  
    // Left face normals
    -1, 0, 0, 0,
    -1, 0, 0, 0,
    -1, 0, 0, 0,
    -1, 0, 0, 0,
  ]);
  
// Define the vertex positions for the cube
this.positions = new Float32Array([
    // Front face
    -1, -1,  1, 1,
     1, -1,  1, 1,
     1,  1,  1, 1,
    -1,  1,  1, 1,
  
    // Back face
    -1, -1, -1, 1,
     1, -1, -1, 1,
     1,  1, -1, 1,
    -1,  1, -1, 1,
  
    // Top face
    -1,  1,  1, 1,
     1,  1,  1, 1,
     1,  1, -1, 1,
    -1,  1, -1, 1,
  
    // Bottom face
    -1, -1,  1, 1,
     1, -1,  1, 1,
     1, -1, -1, 1,
    -1, -1, -1, 1,
  
    // Right face
     1, -1,  1, 1,
     1,  1,  1, 1,
     1,  1, -1, 1,
     1, -1, -1, 1,
  
    // Left face
    -1, -1,  1, 1,
    -1,  1,  1, 1,
    -1,  1, -1, 1,
    -1, -1, -1, 1,
  ]);
  

    this.generateIdx();
    this.generatePos();
    this.generateNor();

    this.count = this.indices.length;
    
    // Upload index buffer to GPU
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);
    
    // Upload normal buffer to GPU
    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
    gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);
    
    // Upload position buffer to GPU
    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
    gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

    console.log(`Created cube`);
  }
};

export default Cube;
