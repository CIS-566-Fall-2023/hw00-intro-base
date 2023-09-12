import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

const numIdx: number = 36;

class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;

  constructor(center: vec3, private scale: number) {
    super(); // Call the constructor of the super class. This is required.
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
  }

  create() {

    // indices
    this.indices = new Uint32Array([0, 1, 2,
                                    0, 2, 3,
                                    4, 5, 6,
                                    4, 6, 7,
                                    8, 9, 10,
                                    8, 10, 11,
                                    12, 13, 14,
                                    12, 14, 15,
                                    16, 17, 18,
                                    16, 18, 19,
                                    20, 21, 22,
                                    20, 22, 23]);

    // Optimization in filling positions, still BUGGY!
    // let pos: vec4[];
    // for (let row = 0; row < 9; row++)
    // {
    //     pos[row * 2] = vec4.fromValues(row - 4, 5, 0, 1);
    //     pos[row * 2 + 1] = vec4.fromValues(row - 4, -5, 0, 1);
    // }
    // for (let col = 0; col < 9; col++)
    // {
    //     pos[col * 2 + 18] = vec4.fromValues(5, col - 4, 0, 1);
    //     pos[col * 2 + 19] = vec4.fromValues(-5, col - 4, 0, 1);
    // }
    // for (let i = 0; i < pos.length; i++)
    // {
    //     this.positions[i] = pos[i][0];
    //     this.positions[i+1] = pos[i][1];
    //     this.positions[i+2] = pos[i][2];
    //     this.positions[i+3] = pos[i][3];
    // }

    this.positions = new Float32Array([-1, -1, 1, 1,
                                        1, -1, 1, 1,
                                        1, 1, 1, 1,
                                        -1, 1, 1, 1,
                                        -1, -1, -1, 1,
                                        -1, 1, -1, 1,
                                        1, 1, -1, 1,
                                        1, -1, -1, 1,
                                    
                                        1, -1, -1, 1,
                                        1, 1, -1, 1,
                                        1, 1, 1, 1,
                                        1, -1, 1, 1,
                                        -1, -1, -1, 1,
                                        -1, -1, 1, 1,
                                        -1, 1, 1, 1,
                                        -1, 1, -1, 1,
                                    
                                        -1, 1, -1, 1,
                                        1, 1, -1, 1,
                                        1, 1, 1, 1,
                                        -1, 1, 1, 1,
                                        -1, -1, -1, 1,
                                        -1, -1, 1, 1,
                                        1, -1, 1, 1,
                                        1, -1, -1, 1]);
    // apply scaling and translation
    for (let i = 0; i < this.positions.length; i+=4) {
        this.positions[i] = this.positions[i] * this.scale + this.center[0];
        this.positions[i+1] = this.positions[i+1] * this.scale + this.center[1];
        this.positions[i+2] = this.positions[i+2] * this.scale + this.center[2];
    }

    // normals
    this.normals = new Float32Array([0, 0, 1, 0,
                                     0, 0, 1, 0,
                                     0, 0, 1, 0,
                                     0, 0, 1, 0,
                                     0, 0, -1, 0,
                                     0, 0, -1, 0,
                                     0, 0, -1, 0,
                                     0, 0, -1, 0,
                                     1, 0, 0, 0,
                                     1, 0, 0, 0,
                                     1, 0, 0, 0,
                                     1, 0, 0, 0,
                                     -1, 0, 0, 0,
                                     -1, 0, 0, 0,
                                     -1, 0, 0, 0,
                                     -1, 0, 0, 0,
                                     0, 1, 0, 0,
                                     0, 1, 0, 0,
                                     0, 1, 0, 0,
                                     0, 1, 0, 0,
                                     0, -1, 0, 0,
                                     0, -1, 0, 0,
                                     0, -1, 0, 0,
                                     0, -1, 0, 0]);

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
