import { vec3, vec4, mat4, glMatrix } from 'gl-matrix';
import {gl} from '../../globals';

class DrawParam {
  color: vec4;
  noiseScale: number;
  displacement: number;
}

export default DrawParam;