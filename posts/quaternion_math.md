---
title: Quaternion and Vector Math
date: '2012-11-15'
description:
categories: [mathematics]
tags: [quaternion, vector, c++, math]
---
Often times I find myself needing to use quaternions to store rotations in my code. They are compact and easy to use, the math however is not always intuitive. 


###Base data structures
"real" defines a floating point number (either float or double)
"real3" and "real4" define data structures containing a vector or a quaternion

<pre>
typedef double real;
struct real3 {
	real x, y, z;
};
struct real4 {
	real w, x, y, z;
};
</pre>

#### Cross and Dot Products

<pre>
inline real3 cross(const real3 &a, const real3 &b)
{
	return R3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}
inline real3 dot(const real3 &a, const real3 &b)
{
	return a.w * b.w + a.x * b.x + a.y * b.y + a.z * b.z;
}
</pre>



###Normalizing a quaternion
Store the inverse of the length to reduce computational cost
<pre>
real4 normalize(const real4 &a)
{
	real length = 1.0/sqrt(a.w * a.w + a.x * a.x + a.y * a.y + a.z * a.z);
	return R4(a.w * length, a.x * length, a.y * length, a.z * length);
}
</pre>

###Quaternion inverse
<pre>
inline real4 inv(const real4 &a)
{
	real4 temp;
	real t1 = a.w * a.w + a.x * a.x + a.y * a.y + a.z * a.z;
	t1 = 1.0 / t1;
	temp.w = t1 * a.w;
	temp.x = -t1 * a.x;
	temp.y = -t1 * a.y;
	temp.z = -t1 * a.z;
	return temp;
}

</pre>
###Add two quaternions
Multiplying two quaternions adds them together
<pre>
inline real4 mult(const real4 &a, const real4 &b)
{
	real4 temp;
	temp.w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z;
	temp.x = a.w * b.x + b.w * a.x + a.y * b.z - a.z * b.y;
	temp.y = a.w * b.y + b.w * a.y + a.z * b.x - a.x * b.z;
	temp.z = a.w * b.z + b.w * a.z + a.x * b.y - a.y * b.x;
	return temp;
}

</pre>

###Rotate a vector by a quaternion
<pre>
inline real3 rotate(const real3 &v, const real4 &q)
{
	real4 r = mult(mult(q, R4(0, v.x, v.y, v.z)), inv(q));
	return R3(r.x, r.y, r.z);
}

</pre>
###Other operations
Some basic multiply/add operations which might be usefull
<pre>
real3 operator +(const real3 &rhs, const real3 &lhs)
{
	real3 temp;
	temp.x = rhs.x + lhs.x;
	temp.y = rhs.y + lhs.y;
	temp.z = rhs.z + lhs.z;
	return temp;
}
real3 operator -(const real3 &rhs, const real3 &lhs)
{
	real3 temp;
	temp.x = rhs.x - lhs.x;
	temp.y = rhs.y - lhs.y;
	temp.z = rhs.z - lhs.z;
	return temp;
}
void operator +=(real3 &rhs, const real3 &lhs)
{
	rhs = rhs + lhs;
}

void operator -=(real3 &rhs, const real3 &lhs)
{
	rhs = rhs - lhs;
}

real3 operator *(const real3 &rhs, const real3 &lhs)
{
	real3 temp;
	temp.x = rhs.x * lhs.x;
	temp.y = rhs.y * lhs.y;
	temp.z = rhs.z * lhs.z;
	return temp;
}

real3 operator *(const real3 &rhs, const real &lhs)
{
	real3 temp;
	temp.x = rhs.x * lhs;
	temp.y = rhs.y * lhs;
	temp.z = rhs.z * lhs;
	return temp;
}

</pre>
