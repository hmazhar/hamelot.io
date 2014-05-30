---
title: OpenGL text without any external libraries
date: '2014-05-30'
description: How to generate a font texture and include it into your code
categories: [visualization]
tags: [texture, freetype, modernGL, opengl, c++]
---

In the world of OpenGL, dealing with text is not always straightforward. GLUT is one method but it's becoming old and in some cases deprecated (OSX 10.9). The freetype2 library is one method for generating text, using this library isn't difficult but getting the best performance requires generating an "Atlas" for your font. An atlas is essentially a texture that contains every single character for a font at a given font size along with information on how to access that character. There are a few libraries that can generate an atlas for you, [freetype-gl](https://github.com/rougier/freetype-gl) being one of them. 

There is an alternative that in my mind is more portable and easier to use. [freetype-gl](https://github.com/rougier/freetype-gl) comes with several awesome little demos on how to use the library, it also comes with a small executable called `makefont` that generates a header file with all of the needed information. 

Provide it with a path for a `.ttf` font, the name of the header file, the font size and the variable name in the header that you will access it with. 

~~~
makefont [--help] --font <font file> --header <header file> --size <font size> --variable <variable name>
~~~

If you find that the texture size is too small go into the code for `makefont.c` and change the following line so that it has the size you require. the default was set to `128x128` and I changed it to `256x256` . If your texture size cannot contain the full font, characters will be missing. Look at the output of the makefont command to make sure that characters are not missing. 

~~~
texture_atlas_t * atlas = texture_atlas_new( 256, 256, 1 );
~~~



There is a demo called `demo-makefont` that demonstrates usage of this file for classic GL, modern GL usage with shaders is slightly different. 

### Shaders

Lets begin with the shaders and that get that out of the way

Vertex:

~~~
#version 330

in vec4 position;
out vec2 texCoords;

void main(void) {
    gl_Position = vec4(position.xy, 0, 1);
    texCoords = position.zw;
}
~~~

Fragment:

~~~
#version 330

uniform sampler2D tex;
in vec2 texCoords;
out vec4 fragColor;

void main(void) {
    fragColor = vec4(1, 1, 1, texture(tex, texCoords).r);
}
~~~

There are two things to notice here, first that the position variable contains both the position and the texture coordinates. Text is 2d so we can get away with this. 3D text would require a few modifications. Second the `.r` value of the texture contains the information we are interested in.


### Initialization

Variables:

~~~
GLuint vbo, vao;
GLuint texture_handle;
GLuint texture, sampler;
~~~

Init code: Generates our texture handle

~~~
   glGenBuffers(1, &vbo);
   glGenVertexArrays(1, &vao);
   glGenTextures(1, &texture);
   glGenSamplers(1, &sampler);
   glSamplerParameteri(sampler, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
   glSamplerParameteri(sampler, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
   glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
   glSamplerParameteri(sampler, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
~~~

Using your shader library/class get the location of the "tex" uniform that was declared in the fragment shader.
I am assuming that the shader has already been initialized/compiled at this point using your shader code. 

~~~
 texture_handle = font_shader.GetUniformLocation("tex");
~~~

Usage, make changes to fit your shader library as needed

~~~
glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

glActiveTexture(GL_TEXTURE0);
glBindTexture(GL_TEXTURE_2D, texture);
glTexImage2D( GL_TEXTURE_2D, 0, GL_R8, font_data.tex_width, font_data.tex_height, 0, GL_RED, GL_UNSIGNED_BYTE, font_data.tex_data);
glBindSampler(0, sampler);
glBindVertexArray(vao);
glEnableVertexAttribArray(0);
glBindBuffer(GL_ARRAY_BUFFER, vbo);

//Enable the shader
font_shader.Use();
glUniform1i(texture_handle, 0);

float sx = 1. / window_size.x;
float sy = 1. / window_size.y;

RenderString(buffer, 0, 0, sx, sy);
glBindTexture(GL_TEXTURE_2D, 0);
glUseProgram(0);
~~~

The render string function 

~~~
#include "FontData.h"
//...
void RenderString(
      const std::string &str,
      float x,
      float y,
      float sx,
      float sy) {
   for (int i = 0; i < str.size(); i++) {
//Find the glyph for the character we are looking for
      texture_glyph_t *glyph = 0;
      for (int j = 0; j < font_data.glyphs_count; ++j) {
         if (font_data.glyphs[j].charcode == str[i]) {
            glyph = &font_data.glyphs[j];
            break;
         }
      }
      if (!glyph) {
         continue;
      }
      x += glyph->kerning[0].kerning;
      float x0 = (float) (x + glyph->offset_x * sx);
      float y0 = (float) (y + glyph->offset_y * sy);
      float x1 = (float) (x0 + glyph->width * sx);
      float y1 = (float) (y0 - glyph->height * sy);

      float s0 = glyph->s0;
      float t0 = glyph->t0;
      float s1 = glyph->s1;
      float t1 = glyph->t1;

      struct {float x, y, s, t;} data[6] = { { x0, y0, s0, t0 }, { x0, y1, s0, t1 }, { x1, y1, s1, t1 }, { x0, y0, s0, t0 }, { x1, y1, s1, t1 }, { x1, y0, s1, t0 } };

      glBufferData(GL_ARRAY_BUFFER, 24 * sizeof(float), data, GL_DYNAMIC_DRAW);
      glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, 0);
      glDrawArrays(GL_TRIANGLES, 0, 6);
      x += (glyph->advance_x * sx);
   }
}
~~~
