import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

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

    let vertices = [
      [-1, -1, -1],
      [1, -1, -1],
      [1, 1, -1],
      [-1, 1, -1],
      [-1, -1, 1],
      [1, -1, 1],
      [1, 1, 1],
      [-1, 1, 1],
    ];
    let vertIndx = [
      0, 1, 3, 3, 1, 2, // front face
      1, 5, 2, 2, 5, 6, // right face
      5, 4, 6, 6, 4, 7, // back face
      4, 0, 7, 7, 0, 3, // left face
      3, 2, 7, 7, 2, 6, // top face
      4, 5, 0, 0, 5, 1, // bottom face 
    ];

    this.indices = new Uint32Array(36);
    for (let i = 0; i < 36; i++) 
    {
      this.indices[i] = i;
    }
      
    this.normals = new Float32Array(4 * 36);
    let idx = 0;
    //Front
    for (let i = 0; i < 6; i++)
    {
      this.normals[idx++] = 0;
      this.normals[idx++] = 0;
      this.normals[idx++] = 1;
      this.normals[idx++] = 0;
    }
    //Right
    for (let i = 0; i < 6; i++)
    {
      this.normals[idx++] = 1;
      this.normals[idx++] = 0;
      this.normals[idx++] = 0;
      this.normals[idx++] = 0;
    }
    //Back
    for (let i = 0; i < 6; i++)
    {
      this.normals[idx++] = 0;
      this.normals[idx++] = 0;
      this.normals[idx++] = -1;
      this.normals[idx++] = 0;
    }
    //Left
    for (let i = 0; i < 6; i++)
    {
      this.normals[idx++] = -1;
      this.normals[idx++] = 0;
      this.normals[idx++] = 0;
      this.normals[idx++] = 0;
    }
    //Top
    for (let i = 0; i < 6; i++)
    {
      this.normals[idx++] = 0;
      this.normals[idx++] = 1;
      this.normals[idx++] = 0;
      this.normals[idx++] = 0;
    }
    //Bottom
    for (let i = 0; i < 6; i++)
    {
      this.normals[idx++] = 0;
      this.normals[idx++] = 0;
      this.normals[idx++] = -1;
      this.normals[idx++] = 0;
    }

    this.positions = new Float32Array(4 * 36);
    for (let i = 0; i < 36; i++) {
      this.positions[i * 4 + 0] = vertices[vertIndx[i]][0] + this.center[0];
      this.positions[i * 4 + 1] = vertices[vertIndx[i]][1] + this.center[1];
      this.positions[i * 4 + 2] = vertices[vertIndx[i]][2] + this.center[2];
      this.positions[i * 4 + 3] = 1;
    }

    this.generateIdx();
    this.generatePos();
    this.generateNor();

    this.count = this.indices.length;
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
    gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
    gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

    console.log(`Created cube`);
  }
};

export default Cube;
