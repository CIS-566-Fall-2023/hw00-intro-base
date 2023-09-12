import {vec3, vec4, mat4, glMatrix} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;

  constructor(center: vec3) {
    super();
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
  }

  create() {
    let verticesOfSingleFace: Array<vec4> = new Array(4);
    verticesOfSingleFace[0] = vec4.fromValues(-1, -1, 1, 1);
    verticesOfSingleFace[1] = vec4.fromValues(1, -1, 1, 1);
    verticesOfSingleFace[2] = vec4.fromValues(1, 1, 1, 1);
    verticesOfSingleFace[3] = vec4.fromValues(-1, 1, 1, 1);

    let normalsOfSingleFace: Array<vec4> = new Array(4);
    normalsOfSingleFace[0] = vec4.fromValues(0, 0, 1, 0);
    normalsOfSingleFace[1] = vec4.fromValues(0, 0, 1, 0);
    normalsOfSingleFace[2] = vec4.fromValues(0, 0, 1, 0);
    normalsOfSingleFace[3] = vec4.fromValues(0, 0, 1, 0);
    
    let vertices: Array<vec4> = new Array();
    let normals: Array<vec4> = new Array();
    let idx = Array();

    //first push the front-facing face as-is
    for(let i = 0; i < 4; i++) {
        vertices.push(verticesOfSingleFace[i]);
        normals.push(normalsOfSingleFace[i]);
    }
    
    let appendRotatedAttrs = (rotMat: mat4) => {
        for(let i = 0; i < 4; i++) {
            let rotatedVec = vec4.create();
            let rotatedNorm = vec4.create();
            vec4.transformMat4(rotatedVec, verticesOfSingleFace[i], rotMat);
            vec4.transformMat4(rotatedNorm, normalsOfSingleFace[i], rotMat);
            vertices.push(rotatedVec);
            normals.push(rotatedNorm);
        }
    };

    //upper face
    let rotateX = mat4.create();
    mat4.fromXRotation(rotateX, glMatrix.toRadian(-90));
    appendRotatedAttrs(rotateX);

    //lower face
    mat4.fromXRotation(rotateX, glMatrix.toRadian(90));
    appendRotatedAttrs(rotateX);

    
    //backward face
    mat4.fromXRotation(rotateX, glMatrix.toRadian(-180));
    appendRotatedAttrs(rotateX);

    //right face
    let rotateY = mat4.create();
    mat4.fromYRotation(rotateY, glMatrix.toRadian(90));
    appendRotatedAttrs(rotateY);

    //left face
    mat4.fromYRotation(rotateY, glMatrix.toRadian(-90));
    appendRotatedAttrs(rotateY);

    
    let id = 0;
    for(let i = 0; i < vertices.length/4; i++) {
        idx.push(id);
        idx.push(id + 1);
        idx.push(id + 2);
        idx.push(id);
        idx.push(id + 2);
        idx.push(id + 3);
        id += 4;
    }

    let v_arr = vertices.map(a=>[...a]).flat();
    let n_arr = normals.map(a=>[...a]).flat();
    this.positions = new Float32Array(v_arr);
    this.normals = new Float32Array(n_arr);
    this.indices = new Uint32Array(idx);
    
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

    console.log(`Created Cube`);
  }
};

export default Cube;