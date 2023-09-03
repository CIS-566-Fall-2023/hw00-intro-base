import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Square extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  uvs: Float32Array;
  center: vec4;
  subdivision: number;

  constructor(center: vec3, subdivision: number) {
    super(); // Call the constructor of the super class. This is required.
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
    this.subdivision = subdivision;
  }

  create() {
    let n = this.subdivision + 1;
    let size = 1.0 / this.subdivision;
    let vertexCount = n * n;
    let indexCount = this.subdivision * this.subdivision * 6;

    this.positions = new Float32Array(vertexCount * 4);
    this.normals = new Float32Array(vertexCount * 4);
    this.uvs = new Float32Array(vertexCount * 2);
    this.indices = new Uint32Array(indexCount);

    for (let i = 0; i < n; i++) {
      for (let j = 0; j < n; j++) {
        let idx = n * i + j;
        this.positions[idx * 4 + 0] = -0.5 + size * j;
        this.positions[idx * 4 + 1] = 0;
        this.positions[idx * 4 + 2] = -0.5 + size * i;
        this.positions[idx * 4 + 3] = 1;

        this.normals[idx * 4 + 0] = 0;
        this.normals[idx * 4 + 1] = 1;
        this.normals[idx * 4 + 2] = 0;
        this.normals[idx * 4 + 3] = 0;

        this.uvs[idx * 2 + 0] = size * j;
        this.uvs[idx * 2 + 1] = size * i;
      }
    }

    for (let i = 0; i < this.subdivision; i++) {
      for (let j = 0; j < this.subdivision; j++) {
        let idx = this.subdivision * i + j;
        let i00 = n * (i + 0) + (j + 0);
        let i01 = n * (i + 0) + (j + 1);
        let i11 = n * (i + 1) + (j + 1);
        let i10 = n * (i + 1) + (j + 0);

        this.indices[idx * 6 + 0] = i00;
        this.indices[idx * 6 + 1] = i01;
        this.indices[idx * 6 + 2] = i11;
        this.indices[idx * 6 + 3] = i00;
        this.indices[idx * 6 + 4] = i11;
        this.indices[idx * 6 + 5] = i10;
      }
    }

    this.generateIdx();
    this.generatePos();
    this.generateNor();
    this.generateUv();

    this.count = this.indices.length;
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
    gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
    gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufUv);
    gl.bufferData(gl.ARRAY_BUFFER, this.uvs, gl.STATIC_DRAW);

    console.log(`Created square`);
  }
};

export default Square;
