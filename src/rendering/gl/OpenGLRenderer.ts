import { mat4, vec4 } from 'gl-matrix';

import Camera from '../../Camera';
import { gl } from '../../globals';

import Drawable from './Drawable';
import ShaderProgram from './ShaderProgram';

// In this file, `gl` is accessible because it is imported above
class OpenGLRenderer {
  startTime: number;

  constructor(public canvas: HTMLCanvasElement) {}

  setClearColor(r: number, g: number, b: number, a: number) {
    gl.clearColor(r, g, b, a);
  }

  setStartTime(time: number) {
    this.startTime = time;
  }

  setSize(width: number, height: number) {
    this.canvas.width = width;
    this.canvas.height = height;
  }

  clear() {
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  }

  render(camera: Camera, prog: ShaderProgram, drawables: Array<Drawable>) {
    const model = mat4.create();
    const viewProj = mat4.create();

    mat4.identity(model);
    mat4.multiply(viewProj, camera.projectionMatrix, camera.viewMatrix);
    prog.setModelMatrix(model);
    prog.setViewProjMatrix(viewProj);
    prog.setTime((Date.now() - this.startTime) * 0.001);
    prog.setCamPos(
      vec4.fromValues(
        camera.controls.eye[0],
        camera.controls.eye[1],
        camera.controls.eye[2],
        1,
      ),
    );

    drawables.forEach((drawable) => {
      prog.draw(drawable);
    });
  }
}

export default OpenGLRenderer;
