import {vec3} from 'gl-matrix';
import {vec4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Cube from './geometry/Cube';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  movingSpeed: 0.2,
  morphingSpeed: 2.0,
  patternSize: 2.0,
  cellNum: 8.0,
  tesselations: 7,
  'Load Scene': loadScene, // A function pointer, essentially
  Color : [255, 0, 0],
};

let cube : Cube;
let icosphere: Icosphere;
let square: Square;
let prevTesselations: number = 7;

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  cube = new Cube(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
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
  gui.add(controls, 'tesselations', 1, 8).step(1);
  gui.add(controls, 'morphingSpeed', 0.05, 4.0);
  gui.add(controls, 'movingSpeed', 0.05, 4.0);
  gui.add(controls, 'patternSize', 0.5, 16.0);
  gui.add(controls, 'cellNum', 0.1, 64.0);
  gui.add(controls, 'Load Scene');
  gui.addColor(controls, 'Color');

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

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);

  let startTime = new Date().getTime();

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
      cube = new Cube(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
      cube.create();
    }

    lambert.setGeometryColor(vec4.fromValues(controls.Color[0] / 255.0, controls.Color[1] / 255.0, controls.Color[2] / 255.0, 1.0));
    lambert.setTime((new Date().getTime() - startTime) / 1000.0);
    lambert.setMovingSpeed(controls.movingSpeed);
    lambert.setPatternSize(controls.patternSize);
    lambert.setCellNum(controls.cellNum);
    lambert.setMorphingSpeed(controls.morphingSpeed);
    renderer.render(camera, lambert, [
      cube,
      // icosphere,
      // square,
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
