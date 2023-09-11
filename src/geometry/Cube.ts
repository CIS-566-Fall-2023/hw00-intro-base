import {vec3, vec4, mat4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

export default class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;

  constructor(center: vec3, public size: number) {
    super(); // Call the constructor of the super class. This is required.
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
  }

  create() {
  // Making Indices
  const indices = [];
  for (let i = 0; i < 6; i++) {
    const x = i * 4
    indices.push(x, x+1, x+2);
    indices.push(x, x+2, x+3); 
  }  
  this.indices = new Uint32Array(indices);
  // Making Normals
  const normals = [];
  for (let i = 0; i < 6; i++) {
    let n;
    n = i % 2 == 0 ? 1 : -1;
    var normal: [number, number, number, number];
    if (i <= 1) {
      normal = [n, 0, 0, 0];
    } else if (i <= 3) {
      normal = [0, n, 0, 0];
    } else {
      normal = [0, 0, n, 0];
    }
    //console.log(normal);
    for (let i = 0; i < 4; i++) {
      normals.push(...normal);
    }
  }
  // Making Positions
  let rot = mat4.create();
  const positions = [];
  for (let i = 0; i < 6; i++) {
    let nor = vec3.fromValues(normals[i*16], normals[i*16 + 1], normals[i*16 + 2]);
    let sign = (nor[0] == 1 || nor[1] == 1 || nor[2] == 1) ? 1 : -1;
    mat4.identity(rot);
    mat4.rotate(rot, rot, Math.PI / 2 , nor);
    let pos = vec4.fromValues(sign, sign, sign, 1);
    console.log(`normal: ${nor[0]}, ${nor[1]}, ${nor[2]}`);
    for (let j = 0; j < 4; j++) {
      vec4.transformMat4(pos, pos, rot);
      console.log(`${pos[0]}, ${pos[1]}, ${pos[2]}, ${pos[3]}`);
      positions.push(...pos);
    }
  }
  console.log(positions)
  this.normals = new Float32Array(normals);
  this.positions = new Float32Array(positions);

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
