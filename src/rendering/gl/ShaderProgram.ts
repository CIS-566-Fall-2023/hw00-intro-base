import {vec2, vec3, vec4, mat3, mat4} from 'gl-matrix';
import Drawable from './Drawable';
import {gl} from '../../globals';

var activeProgram: WebGLProgram = null;

export class Shader {
  shader: WebGLShader;

  constructor(type: number, source: string) {
    this.shader = gl.createShader(type);
    gl.shaderSource(this.shader, source);
    gl.compileShader(this.shader);

    if (!gl.getShaderParameter(this.shader, gl.COMPILE_STATUS)) {
      throw gl.getShaderInfoLog(this.shader);
    }
  }
};

class ShaderProgram {
  prog: WebGLProgram;

  attrPos: number;
  attrNor: number;
  attrCol: number;
  attrUv: number;

  uniformRecord: Map<string, WebGLUniformLocation>;

  constructor(shaders: Array<Shader>) {
    this.prog = gl.createProgram();

    for (let shader of shaders) {
      gl.attachShader(this.prog, shader.shader);
    }
    gl.linkProgram(this.prog);
    if (!gl.getProgramParameter(this.prog, gl.LINK_STATUS)) {
      throw gl.getProgramInfoLog(this.prog);
    }

    this.attrPos = gl.getAttribLocation(this.prog, "vs_Pos");
    this.attrNor = gl.getAttribLocation(this.prog, "vs_Nor");
    this.attrCol = gl.getAttribLocation(this.prog, "vs_Col");
    this.attrUv = gl.getAttribLocation(this.prog, "vs_Uv");
    this.uniformRecord = new Map<string, WebGLUniformLocation>();
  }

  use() {
    if (activeProgram !== this.prog) {
      gl.useProgram(this.prog);
      activeProgram = this.prog;
    }
  }

  getUniformLocation(name: string) {
    if (this.uniformRecord.has(name)) {
      return this.uniformRecord.get(name);
    }
    else {
      let loc = gl.getUniformLocation(this.prog, name);
      this.uniformRecord.set(name, loc);
      return loc;
    }
  }

  setUniformFloat1(name: string, val: GLfloat) {
    let loc = this.getUniformLocation(name);
    if (loc !== -1) {
      gl.uniform1f(loc, val);
    }
  }

  setUniformFloat2(name: string, val: vec2) {
    let loc = this.getUniformLocation(name);
    if (loc !== -1) {
      gl.uniform2fv(loc, val);
    }
  }

  setUniformFloat3(name: string, val: vec3) {
    let loc = this.getUniformLocation(name);
    if (loc !== -1) {
      gl.uniform3fv(loc, val);
    }
  }

  setUniformFloat4(name: string, val: vec4) {
    let loc = this.getUniformLocation(name);
    if (loc !== -1) {
      gl.uniform4fv(loc, val);
    }
  }

  setUniformMatrix3x3(name: string, val: mat3) {
    let loc = this.getUniformLocation(name);
    if (loc !== -1) {
      gl.uniformMatrix3fv(loc, false, val);
    }
  }

  setUniformMatrix4x4(name: string, val: mat4) {
    let loc = this.getUniformLocation(name);
    if (loc !== -1) {
      gl.uniformMatrix4fv(loc, false, val);
    }
  }

  draw(d: Drawable) {
    this.use();

    if (this.attrPos != -1 && d.bindPos()) {
      gl.enableVertexAttribArray(this.attrPos);
      gl.vertexAttribPointer(this.attrPos, 4, gl.FLOAT, false, 0, 0);
    }

    if (this.attrNor != -1 && d.bindNor()) {
      gl.enableVertexAttribArray(this.attrNor);
      gl.vertexAttribPointer(this.attrNor, 4, gl.FLOAT, false, 0, 0);
    }

    if (this.attrUv != -1 && d.bindUv()) {
      gl.enableVertexAttribArray(this.attrUv);
      gl.vertexAttribPointer(this.attrUv, 2, gl.FLOAT, false, 0, 0);
    }

    d.bindIdx();
    gl.drawElements(d.drawMode(), d.elemCount(), gl.UNSIGNED_INT, 0);

    if (this.attrPos != -1) gl.disableVertexAttribArray(this.attrPos);
    if (this.attrNor != -1) gl.disableVertexAttribArray(this.attrNor);
    if (this.attrUv != -1) gl.disableVertexAttribArray(this.attrUv);
  }
};

export default ShaderProgram;
