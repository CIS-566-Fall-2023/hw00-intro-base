import {vec3, vec4, mat4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

export default class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;

  constructor(public size: number) {
    super(); // Call the constructor of the super class. This is required.
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
  // Making Normals and Positions
  let rot = mat4.create();
  const normals = [];
  const positions = [];
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
    mat4.identity(rot);
    // Rotate 4 times around the normal to get each vertex for each face
    mat4.rotate(rot, rot, Math.PI / 2 , vec3.fromValues(normal[0], normal[1], normal[2]));
    // If normal is positive, start from 1,1,1 otherwise start from -1,-1,-1
    n *= this.size;
    let pos = vec4.fromValues(n, n, n, 1);
    // Push normals into the arrays
    for (let j = 0; j < 4; j++) {
      normals.push(...normal);
      vec4.transformMat4(pos, pos, rot);
      positions.push(...pos);
    }
  }
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
