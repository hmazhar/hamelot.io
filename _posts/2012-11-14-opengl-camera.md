---
layout: post
title: OpenGL Camera
date: '2012-11-14'
description: 
categories: [visualization]
tags: [opengl, camera, c++, glut, quaternion]
---

#####UPDATE: For a modern opengl version using GLM please see this [newer post](http://hamelot.co.uk/visualization/moderngl-camera/)

#####UPDATE: Some definitions were mission from code, quaternion and vector classes now included with code

When i'm writing a dynamics code I usually need to visually debug my simulations to make sure everything is initialized properly, looks correct, etc. 
I've found that using OpenGL along with GLUT provides a lightweight solution that I can implement quickly. Usually when I implement a basic rendering code I have a static camera, which in the grand scheme of things is not very useful. 
So after googling OpenGL quaternion cameras I came up with the following solution.
To use this code a basic quaternion class is included. This will be covered in a later post.


####Initialize the camera

The camera requires:

* a position
* a point to look at
* the "up" direction, y is usually up
* a scale for movement

{% highlight c++ %}
OpenGLCamera oglcamera(real3(0,0,-1), real3(0,0,0),real3(0,1,0),1);
{% endhighlight %}

I will update this code with some comments soon.
## Base camera class

{% highlight c++ %}
////////////////////////Quaternion and Vector Code//////////////////////// 
typedef double real;

struct real3 {

	real3(real a = 0, real b = 0, real c = 0): x(a), y(b), z(c) {}

	real x, y, z;
};
struct real4 {

	real4(real d = 0, real a = 0, real b = 0, real c = 0): w(d), x(a), y(b), z(c) {}

	real w, x, y, z;
};

static real3 operator +(const real3 rhs, const real3 lhs)
{
	real3 temp;
	temp.x = rhs.x + lhs.x;
	temp.y = rhs.y + lhs.y;
	temp.z = rhs.z + lhs.z;
	return temp;
}
static real3 operator -(const real3 rhs, const real3 lhs)
{
	real3 temp;
	temp.x = rhs.x - lhs.x;
	temp.y = rhs.y - lhs.y;
	temp.z = rhs.z - lhs.z;
	return temp;
}
static void operator +=(real3 &rhs, const real3 lhs)
{
	rhs = rhs + lhs;
}

static void operator -=(real3 &rhs, const real3 lhs)
{
	rhs = rhs - lhs;
}

static real3 operator *(const real3 rhs, const real3 lhs)
{
	real3 temp;
	temp.x = rhs.x * lhs.x;
	temp.y = rhs.y * lhs.y;
	temp.z = rhs.z * lhs.z;
	return temp;
}

static real3 operator *(const real3 rhs, const real lhs)
{
	real3 temp;
	temp.x = rhs.x * lhs;
	temp.y = rhs.y * lhs;
	temp.z = rhs.z * lhs;
	return temp;
}

static inline real3 cross(real3 a, real3 b)
{
	return real3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}

static real4 Q_from_AngAxis(real angle, real3 axis)
{
	real4 quat;
	real halfang;
	real sinhalf;
	halfang = (angle * 0.5);
	sinhalf = sin(halfang);
	quat.w = cos(halfang);
	quat.x = axis.x * sinhalf;
	quat.y = axis.y * sinhalf;
	quat.z = axis.z * sinhalf;
	return (quat);
}

static real4 normalize(const real4 &a)
{
	real length = 1.0 / sqrt(a.w * a.w + a.x * a.x + a.y * a.y + a.z * a.z);
	return real4(a.w * length, a.x * length, a.y * length, a.z * length);
}

static inline real4 inv(real4 a)
{
	//return (1.0f / (dot(a, a))) * F4(a.x, -a.y, -a.z, -a.w);
	real4 temp;
	real t1 = a.w * a.w + a.x * a.x + a.y * a.y + a.z * a.z;
	t1 = 1.0 / t1;
	temp.w = t1 * a.w;
	temp.x = -t1 * a.x;
	temp.y = -t1 * a.y;
	temp.z = -t1 * a.z;
	return temp;
}

static inline real4 mult(const real4 &a, const real4 &b)
{
	real4 temp;
	temp.w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z;
	temp.x = a.w * b.x + b.w * a.x + a.y * b.z - a.z * b.y;
	temp.y = a.w * b.y + b.w * a.y + a.z * b.x - a.x * b.z;
	temp.z = a.w * b.z + b.w * a.z + a.x * b.y - a.y * b.x;
	return temp;
}

static inline real3 quatRotate(const real3 &v, const real4 &q)
{
	real4 r = mult(mult(q, real4(0, v.x, v.y, v.z)), inv(q));
	return real3(r.x, r.y, r.z);
}

static real4 operator %(const real4 rhs, const real4 lhs)
{
	return mult(rhs, lhs);
}
////////////////////////END Quaternion and Vector Code////////////////////////

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
			dir = real3(0, 0, 1);
			mouse_pos = real3(0, 0, 0);
			camera_pos_delta = real3(0, 0, 0);
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
			real3 mouse_delta = mouse_pos - real3(x, y, 0);
			ChangeHeading(.02 * mouse_delta.x);
			ChangePitch(.02 * mouse_delta.y);
			mouse_pos = real3(x, y, 0);
		}
		void SetPos(int button, int state, int x, int y) {
			mouse_pos = real3(x, y, 0);
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


{% endhighlight %}

##Using with GLUT
In order to use this code with the GLUT library a few more functions are required, it is assumed that oglcamera a OpenGLCamera object. 

{% highlight c++ %}
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
{% endhighlight %}


GKR7HYRJ3T2Q
