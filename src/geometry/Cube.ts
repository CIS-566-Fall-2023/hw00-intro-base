import { mat4, vec3, vec4 } from 'gl-matrix';

import Drawable from '../rendering/gl/Drawable';
import { gl } from '../globals';

const faceData = {
  xPos: {
    normal: vec3.fromValues(1, 0, 0),
    sign: 1,
  },
  xNeg: {
    normal: vec3.fromValues(-1, 0, 0),
    sign: -1,
  },
  yPos: {
    normal: vec3.fromValues(0, 1, 0),
    sign: 1,
  },
  yNeg: {
    normal: vec3.fromValues(0, -1, 0),
    sign: -1,
  },
  zPos: {
    normal: vec3.fromValues(0, 0, 1),
    sign: 1,
  },
  zNeg: {
    normal: vec3.fromValues(0, 0, -1),
    sign: -1,
  },
};

const baseIndices = [0, 1, 2, 0, 2, 3];

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
    // 6 faces, 6 index records per face
    this.indices = new Uint32Array(6 * 6);
    // 6 faces, 4 vertices per face, 4 components per vertex
    this.normals = new Float32Array(6 * 4 * 4);
    this.positions = new Float32Array(6 * 4 * 4);

    for (let face = 0; face < 6; ++face) {
      // gen indices
      baseIndices.forEach((indexOffset, faceIndex) => {
        this.indices[face * 6 + faceIndex] = face * 4 + indexOffset;
      });
    }

    const rotationMatrix = mat4.create();
    const newVertPosition = vec4.create();
    // runs 6x (one per face)
    Object.values(faceData).forEach(({ normal, sign }, faceIndex) => {
      // set up initial vertex + rotation matrix
      vec4.set(newVertPosition, sign, sign, sign, 1);
      mat4.identity(rotationMatrix);
      mat4.rotate(rotationMatrix, rotationMatrix, Math.PI / 2, normal);

      for (let vertex = 0; vertex < 4; ++vertex) {
        const vertexIndex = 16 * faceIndex + 4 * vertex;

        for (let component = 0; component < 3; ++component) {
          this.normals[vertexIndex + component] = normal[component];
          this.positions[vertexIndex + component] =
            newVertPosition[component] + this.center[component];
        }
        this.normals[vertexIndex + 3] = 0;
        this.positions[vertexIndex + 3] = 1;

        // rotate vertex around normal
        vec4.transformMat4(newVertPosition, newVertPosition, rotationMatrix);
      }
    });

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

    // eslint-disable-next-line no-console
    console.log(`Created cube`);
  }
}

export default Cube;
