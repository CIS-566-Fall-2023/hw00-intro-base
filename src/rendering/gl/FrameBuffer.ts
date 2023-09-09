import {vec2, vec3, vec4, mat4} from 'gl-matrix';
import Drawable from './Drawable';
import {gl} from '../../globals';

class FrameBuffer {
  framebuffer: WebGLFramebuffer;
  depthbuffer: WebGLRenderbuffer;
  textureId: WebGLTexture;

  constructor(size: vec2) {
    this.framebuffer = gl.createFramebuffer();
    this.textureId = gl.createTexture();
    this.depthbuffer = gl.createRenderbuffer();

    this.resize(size);
  }

  destory() {
    gl.deleteFramebuffer(this.framebuffer);
    gl.deleteRenderbuffer(this.depthbuffer);
    gl.deleteTexture(this.textureId);
  }

  use() {
    gl.bindFramebuffer(gl.FRAMEBUFFER, this.framebuffer);
  }

  resize(size: vec2)
  {
    this.use();
    gl.bindTexture(gl.TEXTURE_2D, this.textureId);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, size[0], size[1], 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, this.textureId, 0);

    let attachment = [gl.COLOR_ATTACHMENT0];
    gl.drawBuffers(attachment);

    gl.bindRenderbuffer(gl.RENDERBUFFER, this.depthbuffer);
    gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT24, size[0], size[1]);
    gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, this.depthbuffer);

    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
  }

  bindToSlot(slot : number)
  {
    gl.activeTexture(gl.TEXTURE0 + slot);
    gl.bindTexture(gl.TEXTURE_2D, this.textureId);
  }
};

export default FrameBuffer;
