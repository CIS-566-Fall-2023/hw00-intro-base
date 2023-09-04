import {vec3, vec4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import Cube from './geometry/Cube';
import DrawParam from './rendering/gl/DrawParam';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 800,
  color: [1, 0.7, 0.5],
  voronoiScale: 64.0,
  displacement: 0.1,
  'Load Scene': loadScene, // A function pointer, essentially
};

let icosphere: Icosphere;
let square: Square;
let prevTesselations: number = 5;
let cube : Cube;

function loadScene() {
  square = new Square(vec3.fromValues(0, 0, 0), controls.tesselations);
  square.scale = vec3.fromValues(4, 4, 4);
  square.position = vec3.fromValues(0, -1, 0);
  square.create();

  cube = new Cube(vec3.fromValues(0, 0, 0));
  cube.scale = vec3.fromValues(0.2, 0.2, 0.2);
  cube.rotation = vec3.fromValues(45, 45, 45);
  cube.create();
}

function getGUIColor() {
  return vec4.fromValues(controls.color[0] / 255.0, controls.color[1] / 255.0, controls.color[2] / 255.0, 1.0);
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
  gui.add(controls, 'tesselations', 0, 1600).step(1);
  gui.addColor(controls, 'color').setValue([255, 255, 255]);
  gui.add(controls, 'voronoiScale', 0.01, 100.0);
  gui.add(controls, 'displacement', 0, 1);
  gui.add(controls, 'Load Scene');

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

  const customShader = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/custom-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/custom-frag.glsl')),
  ]);

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();

    gl.viewport(0, 0, window.innerWidth, window.innerHeight);

    renderer.clear();

    if(controls.tesselations != prevTesselations) {
      prevTesselations = controls.tesselations;
      loadScene();
    }

    let param = new DrawParam();
    param.color = getGUIColor();
    param.noiseScale = controls.voronoiScale;
    param.displacement = controls.displacement;

    let rotation = 0.4;
    vec3.add(cube.rotation, cube.rotation, vec3.fromValues(rotation, rotation, rotation));

    renderer.render(camera, customShader, param, [
      //icosphere,
      square,
      cube,
    ]);
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
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
  tick();
}

main();
