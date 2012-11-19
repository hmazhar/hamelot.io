---
title: OpenGL Camera
date: '2012-11-14'
description: 
categories: [visualization]
tags: [opengl, camera, c++, glut, quaternion]
---

When i'm writing a dynamics code I usually need to visually debug my simulations to make sure everything is initialized properly, looks correct, etc. 
I've found that using OpenGL along with GLUT provides a lightweight solution that I can implement quickly. Usually when I implement a basic rendering code I have a static camera, which in the grand scheme of things is not very useful. 
So after googling OpenGL quaternion cameras I came up with the following solution.
To use this code a basic quaternion class is recommended. This will be covered in a later post.

I will update this code with some comments soon.
## Base camera class
<pre> 
class OpenGLCamera
{
	public:
		OpenGLCamera(real3 pos, real3 lookat, real3 up, real viewscale) {
			max_pitch_rate = 5;
			max_heading_rate = 5;
			camera_pos = pos;
			look_at = lookat;
			camera_up = up;
			camera_heading = 0;
			camera_pitch = 0;
			dir = R3(0, 0, 1);
			mouse_pos = R3(0, 0, 0);
			camera_pos_delta = R3(0, 0, 0);
			scale = viewscale;
		}
		void ChangePitch(GLfloat degrees) {
			if (fabs(degrees) < fabs(max_pitch_rate)) {
				camera_pitch += degrees;
			} else {
				if (degrees < 0) {
					camera_pitch -= max_pitch_rate;
				} else {
					camera_pitch += max_pitch_rate;
				}
			}

			if (camera_pitch > 360.0f) {
				camera_pitch -= 360.0f;
			} else if (camera_pitch < -360.0f) {
				camera_pitch += 360.0f;
			}
		}
		void ChangeHeading(GLfloat degrees) {
			if (fabs(degrees) < fabs(max_heading_rate)) {
				if (camera_pitch > 90 && camera_pitch < 270 || (camera_pitch < -90 && camera_pitch > -270)) {
					camera_heading -= degrees;
				} else {
					camera_heading += degrees;
				}
			} else {
				if (degrees < 0) {
					if ((camera_pitch > 90 && camera_pitch < 270) || (camera_pitch < -90 && camera_pitch > -270)) {
						camera_heading += max_heading_rate;
					} else {
						camera_heading -= max_heading_rate;
					}
				} else {
					if (camera_pitch > 90 && camera_pitch < 270 || (camera_pitch < -90 && camera_pitch > -270)) {
						camera_heading -= max_heading_rate;
					} else {
						camera_heading += max_heading_rate;
					}
				}
			}

			if (camera_heading > 360.0f) {
				camera_heading -= 360.0f;
			} else if (camera_heading < -360.0f) {
				camera_heading += 360.0f;
			}
		}
		void Move2D(int x, int y) {
			real3 mouse_delta = mouse_pos - R3(x, y, 0);
			ChangeHeading(.02 * mouse_delta.x);
			ChangePitch(.02 * mouse_delta.y);
			mouse_pos = R3(x, y, 0);
		}
		void SetPos(int button, int state, int x, int y) {
			mouse_pos = R3(x, y, 0);
		}
		void Update() {
			real4 pitch_quat, heading_quat;
			real3 angle;
			angle = cross(dir, camera_up);
			pitch_quat = Q_from_AngAxis(camera_pitch, angle);
			heading_quat = Q_from_AngAxis(camera_heading, camera_up);
			real4 temp = (pitch_quat % heading_quat);
			temp = normalize(temp);
			dir = quatRotate(dir, temp);
			camera_pos += camera_pos_delta;
			look_at = camera_pos + dir * 1;
			camera_heading *= .5;
			camera_pitch *= .5;
			camera_pos_delta = camera_pos_delta * .5;
			gluLookAt(camera_pos.x, camera_pos.y, camera_pos.z, look_at.x, look_at.y, look_at.z, camera_up.x, camera_up.y, camera_up.z);
		}
		void Forward() {
			camera_pos_delta += dir * scale;
		}
		void Back() {
			camera_pos_delta -= dir * scale;
		}
		void Right() {
			camera_pos_delta += cross(dir, camera_up) * scale;
		}
		void Left() {
			camera_pos_delta -= cross(dir, camera_up) * scale;
		}
		void Up() {
			camera_pos_delta -= camera_up * scale;
		}
		void Down() {
			camera_pos_delta += camera_up * scale;
		}

		real max_pitch_rate, max_heading_rate;
		real3 camera_pos, look_at, camera_up;
		real camera_heading, camera_pitch, scale;
		real3 dir, mouse_pos, camera_pos_delta;
};
</pre>

##Using with GLUT
In order to use this code with the GLUT library a few more functions are required, it is assumed that oglcamera a OpenGLCamera object. 

<pre>
//OpenGLCamera oglcamera
void CallBackKeyboardFunc(unsigned char key, int x, int y)
{
	switch (key) {
	case 'w':
		oglcamera.Forward();
		break;
	case 's':
		oglcamera.Back();
		break;

	case 'd':
		oglcamera.Right();
		break;

	case 'a':
		oglcamera.Left();
		break;

	case 'q':
		oglcamera.Up();
		break;

	case 'e':
		oglcamera.Down();
		break;
	}
}

void CallBackMouseFunc(int button, int state, int x, int y)
{
	oglcamera.SetPos(button, state, x, y);
}
void CallBackMotionFunc(int x, int y)
{
	oglcamera.Move2D(x, y);
}
</pre>
