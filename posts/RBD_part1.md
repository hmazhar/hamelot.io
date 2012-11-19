---
title: Rigid Body Dynamics Part 1
date: '2012-11-19'
description: Part one of a discussion about rigid body dynamics
categories: [dynamics]
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

Where M is the mass matrix

<div>
\[M = \begin{bmatrix}
M_1& 0& 0& \dotsm & 0 \\
0&\bar{J}_1&0& \dotsm & 0 \\
0&0&M_2& \dotsm & 0 \\
& & &\ddots&\\
0&0&0&\dotsm & \bar{J}_{n_b}
\end{bmatrix}\]
</div>

D is the constraint matrix

<div>
\[D = [D_1, \cdots, D_{n_c}] \in \mathbb{R}^{6n_b \times n_c}\]
</div>

Each constraint is sparse and contains 6 total entries per body

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

* <span>\(\lambda\)</span> is a list of lagrange multipliers, one per constraint
* f is a list of external forces, one per body
* b is a list of constraint correction factors

This problem will be posed as a minimization problem in the form:

<div>
\[min \ q(\lambda)=\frac{1}{2} \lambda^TN\lambda+r^T\lambda \\
N=D^TM^{-1}D \\
r=b+D^TM^{-1}f\]
</div>

Subject to the following constraints 

<div>
\[\lambda \geq 0 , c \geq 0 , \lambda c=0\]
</div>

This quadratic optimization problem can then be solved by solving

<div>
\[N\lambda=r\]
</div>

In part 2 we will cover how to implement a Conjugate Gradient (CG) method for solving this problem

###Details

(Work in Progress)

####Index of Symbols


* M: Mass Matrix
* M_i: Mass of object (3x3 diagonal matrix)
* J_i: Moment of inertia (3x3 Matrix)
* D: Constraint Jacobian Matrix (6* number of bodiex x number of constraints)
* D_i: A single contact constraint
* n_i_A: Normal of contact, note that n_i_A=-n_i-B
* b_i_A, b_i_B, rotational component of jacobian
* \lambda : lagrange multiplier for contact


####Complementarity Condition

The complementarity condition states that either the lagrange multiplier is greater than zero (constraint is not satisfied) or the gap between two bodies is zero and therefore there is no reaction force. If the gap becomes 0 a contact has occurred and a reaction force will be applied. The reaction force results from the nonzero lagrange multiplier.

<div>
\[ 0 \leq D^{(l)T}M^{-1}D^{(l)} \lambda^{(l+1)} + k^{(l)} \perp \lambda^{(l+1)} \geq 0 \]
</div>

####Computing the Contact Jacobian





