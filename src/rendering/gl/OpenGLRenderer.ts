import {mat4, vec3, vec4} from 'gl-matrix';
import Drawable from './Drawable';
import DrawParam from './DrawParam';
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

  render(camera: Camera, prog: ShaderProgram, param: DrawParam, drawables: Array<Drawable>) {
    prog.use();

    let viewProj = mat4.create();
    let time = this.frameCount / 60.0;

    mat4.multiply(viewProj, camera.projectionMatrix, camera.viewMatrix);

    prog.setUniformMatrix4x4("u_ViewProj", viewProj);
    prog.setUniformFloat4("u_Color", param.color);
    prog.setUniformFloat1("u_VoronoiScale", param.noiseScale);
    prog.setUniformFloat1("u_Time", time);
    prog.setUniformFloat1("u_Displacement", param.displacement);

    //gl.uniform1fv(gl.getUniformLocation(prog.prog, "u_FragmentTime"), [0.3]);

    for (let drawable of drawables) {
      let model = drawable.getTransform();
      let modelInvT = mat4.create();
      let modelView = mat4.create();
      mat4.multiply(modelView, camera.viewMatrix, model);
      mat4.transpose(modelInvT, model);
      mat4.invert(modelInvT, modelInvT);
      prog.setUniformMatrix4x4("u_Model", model);
      prog.setUniformMatrix4x4("u_ModelInvTr", modelInvT);
      prog.setUniformMatrix4x4("u_ModelView", modelView);
      prog.draw(drawable);
    }
    this.frameCount++;
  }
};

export default OpenGLRenderer;
