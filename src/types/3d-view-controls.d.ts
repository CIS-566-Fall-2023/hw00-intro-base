declare module '3d-view-controls' {
  import { vec3 } from 'gl-matrix';

  export default function CameraControls(
    element: HTMLElement,
    options: { eye: vec3; center: vec3 },
  ): {
    eye: vec3;
    center: vec3;
    up: vec3;
    tick: () => void;
  };
}
