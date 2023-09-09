import {mat4, vec3, vec4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import Cube from './geometry/Cube';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {ShaderData, Shader} from './rendering/gl/ShaderProgram';
import Drawable from './rendering/gl/Drawable';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
  'Debug Noise': false,
  // colors
  col: {
    r: 0.5,
    g: 0.5,
    b: 0.5
  }
};

let icosphere: Icosphere;
let square: Square;
let cube: Cube;
let prevTesselations: number = 5;
let rotAngle: number = 0;
let lastTime: number = 0;

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  cube = new Cube(vec3.fromValues(0, 0, 0), vec3.fromValues(1, 1, 1));
  cube.create();
}

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');
  gui.add(controls, 'Debug Noise');
  const folder = gui.addFolder('Color');
  folder.add(controls.col, 'r', 0, 1).step(0.01);
  folder.add(controls.col, 'g', 0, 1).step(0.01);
  folder.add(controls.col, 'b', 0, 1).step(0.01);
  folder.open();

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);

  // This function will be called every frame
  function tick(timeStamp : number) {
    // log
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();

    let header : string = '#version 300 es\nprecision highp float;\n'
    let t = timeStamp / 1000.0;
    let dt = (timeStamp - lastTime) / 1000.0;

    if (!controls['Debug Noise']) {
      if(controls.tesselations != prevTesselations) {
        prevTesselations = controls.tesselations;
        icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
        icosphere.create();
      }

      renderer.render(camera, 
        new ShaderProgram([
          new Shader(gl.VERTEX_SHADER, [header, require('./shaders/lambert-vert.glsl')]),
          new Shader(gl.FRAGMENT_SHADER, [header, require('./shaders/perlin.glsl'), require('./shaders/lambert-frag.glsl')]),
        ]),
        [cube],
        new ShaderData(
          mat4.create(),
          vec4.fromValues(controls.col.r, controls.col.g, controls.col.b, 1),
          t
      ));

      let scale : number = 0.4 + 0.1 * Math.sin(t);
      rotAngle += 60 * dt;
      let model = mat4.scale(mat4.create(), mat4.create(), vec3.fromValues(scale, scale, scale));
      model = mat4.rotateY(model, model, rotAngle * Math.PI / 180.0);

      renderer.render(camera, 
        new ShaderProgram([
          new Shader(gl.VERTEX_SHADER, [header, require('./shaders/perlin.glsl'), require('./shaders/tumor-vert.glsl')]),
          new Shader(gl.FRAGMENT_SHADER, [header, require('./shaders/perlin.glsl'), require('./shaders/tumor-frag.glsl')]),
        ]),
        [icosphere],
        new ShaderData(
          model,
          vec4.create(),
          t)
      );
    } else {
      renderer.render(camera,
        new ShaderProgram([
          new Shader(gl.VERTEX_SHADER, [header, require('./shaders/noise-vert.glsl')]),
          new Shader(gl.FRAGMENT_SHADER, [header, require('./shaders/perlin.glsl'), require('./shaders/noise-frag.glsl')]),
        ]),
        [square],
        new ShaderData(
          mat4.create(),
          vec4.fromValues(controls.col.r, controls.col.g, controls.col.b, 1),
          t
        )
      );
    }
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    lastTime = timeStamp;
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  requestAnimationFrame(tick);
}

main();
