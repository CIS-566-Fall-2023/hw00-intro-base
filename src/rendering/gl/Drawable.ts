import { vec3, vec4, mat4, glMatrix } from 'gl-matrix';
import {gl} from '../../globals';

abstract class Drawable {
  count: number = 0;

  bufIdx: WebGLBuffer;
  bufPos: WebGLBuffer;
  bufNor: WebGLBuffer;
  bufUv: WebGLBuffer;

  idxBound: boolean = false;
  posBound: boolean = false;
  norBound: boolean = false;
  uvBound: boolean = false;

  position: vec3 = vec3.fromValues(0, 0, 0);
  rotation: vec3 = vec3.fromValues(0, 0, 0);
  scale: vec3 = vec3.fromValues(1, 1, 1);

  abstract create(): void;

  getTransform() {
    let tr = mat4.create();
    mat4.identity(tr);
    mat4.translate(tr, tr, this.position);
    mat4.scale(tr, tr, this.scale);
    mat4.rotate(tr, tr, glMatrix.toRadian(this.rotation[0]), vec3.fromValues(0, 0, 1));
    mat4.rotate(tr, tr, glMatrix.toRadian(this.rotation[1]), vec3.fromValues(1, 0, 0));
    mat4.rotate(tr, tr, glMatrix.toRadian(this.rotation[2]), vec3.fromValues(0, 1, 0));
    return tr;
  }

  destory() {
    gl.deleteBuffer(this.bufIdx);
    gl.deleteBuffer(this.bufPos);
    gl.deleteBuffer(this.bufNor);
    gl.deleteBuffer(this.bufUv);
  }

  generateIdx() {
    this.idxBound = true;
    this.bufIdx = gl.createBuffer();
  }

  generatePos() {
    this.posBound = true;
    this.bufPos = gl.createBuffer();
  }

  generateNor() {
    this.norBound = true;
    this.bufNor = gl.createBuffer();
  }

  generateUv() {
    this.uvBound = true;
    this.bufUv = gl.createBuffer();
  }

  bindIdx(): boolean {
    if (this.idxBound) {
      gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
    }
    return this.idxBound;
  }

  bindPos(): boolean {
    if (this.posBound) {
      gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
    }
    return this.posBound;
  }

  bindNor(): boolean {
    if (this.norBound) {
      gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
    }
    return this.norBound;
  }

  bindUv() : boolean {
    if (this.uvBound) {
      gl.bindBuffer(gl.ARRAY_BUFFER, this.bufUv);
    }
    return this.uvBound;
  }

  elemCount(): number {
    return this.count;
  }

  drawMode(): GLenum {
    return gl.TRIANGLES;
  }
};

export default Drawable;