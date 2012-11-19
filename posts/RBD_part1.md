---
title: Rigid Body Dynamics Part 1
date: '2012-11-19'
description: Part one of a discussion about rigid body dynamics
categories: [dynamics]
tags: [dynamics, physics, math, shur compliment, optimization, contact, constraint, frictionless]
---


This is part 1 of a multipart series in which I will be discussing the basics of rigid body dynamics. For simplicity I will start out with the frictionless case and the geometry used will only consist of spheres. Constraints considered will only be of the contact variety.

In part 1 I will go over a very high level overview of the steps involved with solving the frictionless problem along with some of the math behind the problem.

### The Rigid Body Dynamics Problem
<div>
\[\begin{bmatrix}
M & D\\ 
D^T & 0
\end{bmatrix}*
\begin{bmatrix}
q \\ 
\lambda 
\end{bmatrix}-
\begin{bmatrix}
f \\ 
b
\end{bmatrix}=
\begin{bmatrix}
0 \\ 
c 
\end{bmatrix}\]
</div>

By taking the [Shur Compliment](http://en.wikipedia.org/wiki/Schur_complement) of the system of equations the problem can be posed as a minimization problem in the form:

<div>
\[min \ q(\lambda)=\frac{1}{2} \lambda^TN\lambda+r^T\lambda \\
N=D^TM^{-1}D \\
r=b+D^TM^{-1}f\]
</div>

Subject to the following constraints 

<div>
\[\lambda \geq 0 , c \geq 0 , \lambda c=0\]
</div>

This quadratic optimization problem can then be solved in a straightforward manner. 

<div>
\[N\lambda=r\]
</div>

####Complementarity Condition

The complementarity condition states that either the lagrange multiplier is greater than zero (constraint is not satisfied) or the gap between two bodies is zero and therefore there is no reaction force. If the gap becomes 0 a contact has occurred and a reaction force will be applied. The reaction force results from the nonzero lagrange multiplier.

<div>
\[ 0 \leq D^{(l)T}M^{-1}D^{(l)} \lambda^{(l+1)} + k^{(l)} \perp \lambda^{(l+1)} \geq 0 \]
</div>

###Details

(Work in Progress)

####Index of Symbols


* \\(n_b\\) : number of bodies
* \\(n_c\\) : number of contacts


M is the mass matrix

<div>
\[M = \begin{bmatrix}
M_1& 0& 0& \dotsm & 0 \\
0&\bar{J}_1&0& \dotsm & 0 \\
0&0&M_2& \dotsm & 0 \\
& & &\ddots&\\
0&0&0&\dotsm & \bar{J}_{n_b}
\end{bmatrix}\]
</div>

* \\(M_i\\) : Mass of object (3x3 diagonal matrix)
* \\(\bar{J}_i\\) : Moment of inertia (3x3 Matrix)

D is the contact constraint matrix

<div>
\[D = [D_1, \cdots, D_{n_c}] \in \mathbb{R}^{6n_b \times n_c}\]
</div>

Each constraint is sparse and contains 6 total entries per body. More details will be provided in the next section.

<div>
\[D_i =
\begin{bmatrix}
0\\
\vdots\\
n_{i,A}\\
b_{i,A}\\
\vdots\\
n_{i,B}\\
b_{i,B}\\
0
\end{bmatrix}\]
</div>

* \\(\lambda\\) is a list of lagrange multipliers, one per constraint
* f is a list of external forces (ex: gravity) , one per body
* b is a list of contact constraint correction factors


####Computing the Contact Jacobian

* For each body we have a rotation matrix \\(A\\)
* Each contact has a contact normal \\(n\\)

In the local reference frame (LRF) of each body the contact normal becomes

\\(\bar{n}=A^Tn\\)

\\(\bar{s}\\) is the contact point in the LRF and \\(\tilde{\bar{s}}\\) is the skew symmetric form of \\(\bar{s}\\)

The contact Jacobian for each body consists of the normal \\(n\\) and \\(b\\) where \\(b\\) is defined as:

\\(\bar{b} = \tilde{\bar{s}}.\bar{n}\\) 

note that the contact normal for each body is opposite of the other body


In part 2 we will cover how to implement a Conjugate Gradient (CG) method for solving this problem along with how to enforce the contact constraints. 