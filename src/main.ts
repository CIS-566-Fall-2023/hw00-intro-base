import * as DAT from 'dat.gui';
import { vec3, vec4 } from 'gl-matrix';
import Stats from 'stats-js';

import Camera from './Camera';
import { GAMMA } from './constants';
import Cube from './geometry/Cube';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import { setGL } from './globals';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import ShaderProgram, { Shader } from './rendering/gl/ShaderProgram';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  color: [255, 0, 0] as [number, number, number],
  'Load Scene': loadScene, // A function pointer, essentially
};

let icosphere: Icosphere;
let square: Square;
let cube: Cube;
let prevTesselations: number = controls.tesselations;
let prevColor = [0, 0, 0] as [number, number, number];

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  cube = new Cube(vec3.fromValues(0, 0, 0));
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
  gui.addColor(controls, 'color');

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement>document.getElementById('canvas');
  const gl = <WebGL2RenderingContext>canvas.getContext('webgl2');
  if (!gl) {
    // eslint-disable-next-line no-alert
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
  lambert.setGeometryColor([1, 0, 0, 1]);

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    if (controls.tesselations !== prevTesselations) {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }
    if (!vec3.equals(controls.color, prevColor)) {
      prevColor = controls.color;
      const newColor = vec4.fromValues(...prevColor, 0);
      vec4.scale(newColor, newColor, 1 / 256);
      for (let component = 0; component < 3; ++component) {
        newColor[component] **= GAMMA;
      }
      newColor[3] = 1;
      lambert.setGeometryColor(newColor);
    }
    renderer.render(camera, lambert, [
      // icosphere,
      cube,
    ]);
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener(
    'resize',
    () => {
      renderer.setSize(window.innerWidth, window.innerHeight);
      camera.setAspectRatio(window.innerWidth / window.innerHeight);
      camera.updateProjectionMatrix();
    },
    false,
  );

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
