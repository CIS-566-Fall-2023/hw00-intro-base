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

    this.indices = new Uint32Array([
      0, 1, 2,
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
      20, 22, 23,

      24, 25, 26,
      24, 26, 27
    ]);
    this.normals = new Float32Array([
      //front
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,
      //Right
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      //Left
      -1, 0, 0,
      -1, 0, 0,
      -1, 0, 0,
      -1, 0, 0,
      //Back
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,
      //Top
      0, 1, 0,
      0, 1, 0,
      0, 1, 0,
      0, 1, 0,
      //Bottom
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,
      0, -1, 0
    ]);
    this.positions = new Float32Array([
      //Front		
      1.0, 1.0, 1.0, 1.0,
      //LR
      1.0, 0.0, 1.0, 1.0,
      //LL
      0.0, 0.0, 1.0, 1.0,
      //UL
      0.0, 1.0, 1.0, 1.0,

      //Right
      //UR
      1.0, 1.0, 0.0, 1.0,
      //LR
      1.0, 0.0, 0.0, 1.0,
      //LL
      1.0, 0.0, 1.0, 1.0,
      //UL
      1.0, 1.0, 1.0, 1.0,

      //Left
      //UR
      0.0, 1.0, 1.0, 1.0,
      //LR
      0.0, 0.0, 1.0, 1.0,
      //LL
      0.0, 0.0, 0.0, 1.0,
      //UL
      0.0, 1.0, 0.0, 1.0,

      //Back
      //UR
      0.0, 1.0, 0.0, 1.0,
      //LR
      0.0, 0.0, 0.0, 1.0,
      //LL
      1.0, 0.0, 0.0, 1.0,
      //UL
      1.0, 1.0, 0.0, 1.0,

      //Top
      //UR
      1.0, 1.0, 0.0, 1.0,
      //LR
      1.0, 1.0, 1.0, 1.0,
      //LL
      0.0, 1.0, 1.0, 1.0,
      //UL
      0.0, 1.0, 0.0, 1.0,

      //Bottom
      //UR
      1.0, 0.0, 1.0, 1.0,
      //LR
      1.0, 0.0, 0.0, 1.0,
      //LL
      0.0, 0.0, 0.0, 1.0,
      //UL
      0.0, 0.0, 1.0, 1.0
    ]);
    for(let i=0;i<24;++i){
      let idx0 = i*4;
      this.positions[idx0]-=0.5;
      this.positions[idx0+1]-=0.5;
      this.positions[idx0+2]-=0.5;
      this.positions[idx0+3]-=0.5;
      // this.positions[idx0]*=2;
      // this.positions[idx0+1]*=2;
      // this.positions[idx0+2]*=2;
      // this.positions[idx0+3]*=2;
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
