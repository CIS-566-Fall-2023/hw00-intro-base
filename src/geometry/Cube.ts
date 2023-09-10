// Add a Cube class that inherits from Drawable 
// implement a constructor and its create function. 
// Then, add a Cube instance to the scene to be rendered.

import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable {
  
//   buffer: ArrayBuffer;
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;

  constructor(center: vec3) {
    super(); // Call the constructor of the super class. This is required.
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
  }

  create() {

    this.indices = new Uint32Array(36);

    let j = 0;
    for (let i = 0; i < 36; i += 6) {
        this.indices[i] = j;
        this.indices[i + 1] = j + 1;
        this.indices[i + 2] = j + 3;
        this.indices[i + 3] = j ;
        this.indices[i + 4] = j + 3;
        this.indices[i + 5] = j + 2;
        j += 4;
    }

    this.positions = new Float32Array(
        [-1, 1, 1, 1, // 0
        1, 1, 1, 1,
        -1, -1, 1, 1,
        1, -1, 1, 1,

        -1, 1, -1, 1, // 4
        1, 1, -1, 1,
        -1, 1, 1, 1,
        1, 1, 1, 1,

        -1, 1, -1, 1, // 8
        -1, 1, 1, 1,
        -1, -1, -1, 1,
        -1, -1, 1, 1,

        1, 1, 1, 1, // 12
        1, 1, -1, 1,
        1, -1, 1, 1,
        1, -1, -1, 1,

        1, 1, -1, 1, // 16
        -1, 1, -1, 1,
        1, -1, -1, 1,
        -1, -1, -1, 1,

        -1, -1, 1, 1, // 20
        1, -1, 1, 1,
        -1, -1, -1, 1,
        1, -1, -1, 1]);

    this.normals = new Float32Array(96);

    for (let i = 0; i < 16; i += 4) {
        this.normals[i] = 0;
        this.normals[i + 1] = 0;
        this.normals[i + 2] = 1;
        this.normals[i + 3] = 0;
    }

    for (let i = 16; i < 32; i += 4) {
        this.normals[i] = 0;
        this.normals[i + 1] = 1;
        this.normals[i + 2] = 0;
        this.normals[i + 3] = 0;
    }
    
    for (let i = 32; i < 48; i += 4) {
        this.normals[i] = -1;
        this.normals[i + 1] = 0;
        this.normals[i + 2] = 0;
        this.normals[i + 3] = 0;
    }
    
    for (let i = 48; i < 64; i += 4) {
        this.normals[i] = 1;
        this.normals[i + 1] = 0;
        this.normals[i + 2] = 0;
        this.normals[i + 3] = 0;
    }
    
    for (let i = 64; i < 80; i += 4) {
        this.normals[i] = 0;
        this.normals[i + 1] = 0;
        this.normals[i + 2] = -1;
        this.normals[i + 3] = 0;
    }
   
    for (let i = 80; i < 96; i += 4) {
        this.normals[i] = 0;
        this.normals[i + 1] = -1;
        this.normals[i + 2] = 0;
        this.normals[i + 3] = 0;
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
