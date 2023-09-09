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

    const facesPerCube = 6
    this.indices = new Uint32Array(3 * 2 * facesPerCube);
    for (let i = 0; i < facesPerCube; i++){
      let indexOffset = i * 3 * 2
      let vertexOffset = i * 4
      this.indices[indexOffset + 0] = vertexOffset + 0
      this.indices[indexOffset + 1] = vertexOffset + 1
      this.indices[indexOffset + 2] = vertexOffset + 2
      this.indices[indexOffset + 3] = vertexOffset + 0
      this.indices[indexOffset + 4] = vertexOffset + 2
      this.indices[indexOffset + 5] = vertexOffset + 3
    }

    this.normals = new Float32Array([0, 0, 1, 0, //front
                                    0, 0, 1, 0,
                                    0, 0, 1, 0,
                                    0, 0, 1, 0,
                                    0, 0, 1, 0, //back
                                    0, 0, 1, 0,
                                    0, 0, 1, 0,
                                    0, 0, 1, 0,
                                    1, 0, 0, 0, //right
                                    1, 0, 0, 0,
                                    1, 0, 0, 0,
                                    1, 0, 0, 0,
                                    1, 0, 0, 0, //left
                                    1, 0, 0, 0,
                                    1, 0, 0, 0,
                                    1, 0, 0, 0,
                                    0, 1, 0, 0, //top
                                    0, 1, 0, 0,
                                    0, 1, 0, 0,
                                    0, 1, 0, 0,
                                    0, 1, 0, 0, //bottom
                                    0, 1, 0, 0,
                                    0, 1, 0, 0,
                                    0, 1, 0, 0]);
    this.positions = new Float32Array([-1, -1, 1, 1, //front
                                        1, -1, 1, 1,
                                        1, 1, 1, 1,
                                        -1, 1, 1, 1,
                                        -1, -1, -1, 1, //back
                                        1, -1, -1, 1,
                                        1, 1, -1, 1,
                                        -1, 1, -1, 1,
                                        1, -1, 1, 1, //right
                                        1, -1, -1, 1,
                                        1, 1, -1, 1,
                                        1, 1, 1, 1,
                                        -1, -1, -1, 1, //left
                                        -1, -1, 1, 1,
                                        -1, 1, 1, 1,
                                        -1, 1, -1, 1,
                                        -1, -1, -1, 1, //top
                                        1, -1, -1, 1,
                                        1, -1, 1, 1,
                                        -1, -1, 1, 1,
                                        -1, 1, 1, 1, //bottom
                                        1, 1, 1, 1,
                                        1, 1, -1, 1,
                                        -1, 1, -1, 1]);

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

    console.log(`Created square instead of cube`);
  }

};

export default Cube;