import {vec3, vec4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL, gl} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import Drawable from './rendering/gl/Drawable';

// Create a Cube class
class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;

  constructor(center: vec3) {
    super();
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
  }

  create(): void {
    this.indices = new Uint32Array([0, 1, 2, // front
                                    0, 2, 3,
                                    4, 5, 6, // back
                                    4, 6, 7,
                                    8, 9, 10, // left
                                    8, 10, 11,
                                    12, 13, 14, // right
                                    12, 14, 15,
                                    16, 17, 18, // top
                                    16, 18, 19,
                                    20, 21, 22, // botom
                                    20, 22, 23]);
    
    this.normals = new Float32Array([-1, 1, 1, 1, // front
                                        1, 1, 1, 1,
                                        1, -1, 1, 1,
                                        -1, -1, 1, 1,
                                        -1, 1, -1, 1, // back
                                        1, 1, -1, 1,
                                        1, -1, -1, 1,
                                        -1, -1, -1, 1,
                                        -1, 1, 1, 1, // left
                                        -1, 1, -1, 1,
                                        -1, -1, -1, 1,
                                        -1, -1, 1, 1,
                                        1, 1, 1, 1, // right
                                        1, 1, -1, 1,
                                        1, -1, -1, 1,
                                        1, -1, 1, 1,
                                        -1, 1, 1, 1, // top
                                        -1, 1, -1, 1,
                                        1, 1, -1, 1,
                                        1, 1, 1, 1,
                                        -1, -1, -1, 1, // bottom
                                        1, -1, -1, 1,
                                        1, -1, 1, 1,
                                        -1, -1, 1, 1]);
    this.positions = new Float32Array([-1, 1, 1, 1, // front
                                        1, 1, 1, 1,
                                        1, -1, 1, 1,
                                        -1, -1, 1, 1,
                                        -1, 1, -1, 1, // back
                                        1, 1, -1, 1,
                                        1, -1, -1, 1,
                                        -1, -1, -1, 1,
                                        -1, 1, 1, 1, // left
                                        -1, 1, -1, 1,
                                        -1, -1, -1, 1,
                                        -1, -1, 1, 1,
                                        1, 1, 1, 1, // right
                                        1, 1, -1, 1,
                                        1, -1, -1, 1,
                                        1, -1, 1, 1,
                                        -1, 1, 1, 1, // top
                                        -1, 1, -1, 1,
                                        1, 1, -1, 1,
                                        1, 1, 1, 1,
                                        -1, -1, -1, 1, // bottom
                                        1, -1, -1, 1,
                                        1, -1, 1, 1,
                                        -1, -1, 1, 1]);

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

    console.log(`Created cube`);
  }
}


// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  color: [0, 128, 255],
  'Load Scene': loadScene, // A function pointer, essentially
};

let icosphere: Icosphere;
let square: Square;
let prevTesselations: number = 5;
let cube: Cube;
let time: number;

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
  time = 0;

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');
  gui.addColor(controls, 'color');

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
    // new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    // new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
    new Shader(gl.VERTEX_SHADER, require('./shaders/deform-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/noise-frag.glsl')),
  ]);

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    time += 1;

    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }

    renderer.render(camera, lambert, [
      // icosphere,
      // square,
      cube
      ],
      vec4.fromValues(controls.color[0] / 256, controls.color[1] / 256, controls.color[2] / 256, 1),
      time);
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
