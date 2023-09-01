import {mat4, vec3, vec4} from 'gl-matrix';
import Drawable from './Drawable';
import Camera from '../../Camera';
import {gl} from '../../globals';
import ShaderProgram from './ShaderProgram';

// In this file, `gl` is accessible because it is imported above
class OpenGLRenderer {
  frameCount: number;

  constructor(public canvas: HTMLCanvasElement) {
    this.frameCount = 0.0;
  }

  setClearColor(r: number, g: number, b: number, a: number) {
    gl.clearColor(r, g, b, a);
  }

  setSize(width: number, height: number) {
    this.canvas.width = width;
    this.canvas.height = height;
  }

  clear() {
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  }

  render(camera: Camera, prog: ShaderProgram, color: vec4, drawables: Array<Drawable>) {
    prog.use();

    let model = mat4.create();

    let viewProj = mat4.create();
    let time = this.frameCount / 120.0;

    mat4.identity(model);
    //mat4.rotate(model, model, time, vec3.fromValues(0, 0, 1));

    let modelinvtr = mat4.create();
    mat4.transpose(modelinvtr, model);
    mat4.invert(modelinvtr, modelinvtr);

    mat4.multiply(viewProj, camera.projectionMatrix, camera.viewMatrix);

    prog.setUniformMatrix4x4("u_Model", model);
    prog.setUniformMatrix4x4("u_ModelInvTr", modelinvtr);
    prog.setUniformMatrix4x4("u_ViewProj", viewProj);
    prog.setUniformFloat4("u_Color", color);
    prog.setUniformFloat1("u_Time", time);

    //gl.uniform1fv(gl.getUniformLocation(prog.prog, "u_FragmentTime"), [0.3]);

    for (let drawable of drawables) {
      prog.draw(drawable);
    }
    this.frameCount++;
  }
};

export default OpenGLRenderer;
