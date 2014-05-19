---
title: Complementarity Frictional Contact In GAMS
date: '2014-5-19'
description: Solving Complementarity Frictional Contact Models in GAMS
categories: [programming]
tags: [gams, programming, contact, constraint, optimization, math, physics]
---


The purpose of this post is to detail work done by [Dan Melanz](http://danielmelanz.com/) and I on the topic of solving frictional contact problems using the [General Algebraic Modeling System (GAMS)](http://www.gams.com/)

The best way to describe GAMS is that it is a language and framework for writing mathematical programming and optimization problems. GAMS can solve many different classes of problems, in this post the Nonlinear Programming (NLP), Quadratically Constrained Program (QCP) and Extended Mathematical Program (EMP) problem types will be discussed. 

##References

These papers provide more details about the various formulations used in this post. 

####Primal Model:

V. Acary and F. Cadoux, “Applications of an Existence Result for the Coulomb Friction Problem,” Recent Advances in Contact Mechanics, pp. 45–66, 2013.

V. Acary, F. Cadoux, C. Lemaréchal, and J. Malick, “A formulation of the linear discrete Coulomb friction problem via convex optimization,” Z. angew. Math. Mech., vol. 91, no. 2, pp. 155–175, Feb. 2011.

F. Bertails-Descoubes, F. Cadoux, G. Daviet, and V. Acary, “A nonsmooth Newton solver for capturing exact Coulomb friction in fiber assemblies,” ACM Transactions on Graphics, vol. 30, no. 1, pp. 1–14, Jan. 2011.

####Dual Model

M. Anitescu and G. D. Hart, “A constraint-stabilized time-stepping approach for rigid multibody dynamics with joints, contact and friction,” Int. J. Numer. Meth. Engng., vol. 60, no. 14, pp. 2335–2371, Aug. 2004.

A. Tasora and M. Anitescu, “A complementarity-based rolling friction model for rigid contacts,” Meccanica, vol. 48, no. 7, pp. 1643–1659, Sep. 2013.


##Equations of Motion (EOM)

#### Variables and symbols

 - $$M$$ - Mass Matrix
 - $$D$$ - Jacobian Matrix
 - $$q$$ - Positions
 - $$v$$ - Velocities
 - $$\widehat{\gamma}$$ - Reaction Forces
 - $$\gamma$$ - Reaction Impulses
 - $$h$$ - Time Step
 - $$\mu$$ - Friction Constant
 - $$N$$ - Shur Complement Matrix
 - $$r$$ - Shur Complement Right Hand Side 
 - $$\Upsilon_i$$ - Friction Code
 - $$\Upsilon_i^{\circ}$$ - Polar Friction Cone


Below are the Equations for motion for a system of rigid bodies that have contact (unilateral) and joint (bilateral) constraints.  
The second equation is a simple force balance stating $$M \bf{\dot v} =f $$ where the forces comprise of applied forces such as gravity, reaction forces from joints and frictional contact forces. The next equation states that the joints must be satisfied at the position level (No drift). The complementarity condition states that the lagrange multiplier $$ \widehat{\gamma}_{i,n} $$ is positive when the gap $$\Phi_{i} $$ is zero and vice versa, a zero reaction force means that the gap is positive. 

#### Force-Acceleration Form
<div>
 \begin{align}

\newcommand{\cA}{ {\cal A} }
\newcommand{\HC}[1]{ \rlap{\text{#1} } }
\newcommand{\hatGN}[1]{ {\widehat{\gamma}_{#1,n} } }
\newcommand{\hatGU}[1]{ {\widehat{\gamma}_{#1,u} } }
\newcommand{\hatGW}[1]{ {\widehat{\gamma}_{#1,w} } }
\newcommand{\AppliedF}{ { {\bf{f} }\left( {t,  {\bf q} , {\bf v} } \right)} }
\newcommand{\ReactF}{ { { {\bf{g} }_{\bf q}^{\rm{T} }({ {\bf q} },t){\lambda } } } }
\newcommand{\FricConF}{\left( \hatGN{i}\Pn{i} + \hatGU{i} \Ptu{i}  + \hatGW{i} \Ptw{i}  \right)}
\newcommand{\DissipEnergy}{ {\bf v}^T \left( \bar \gamma _u^i \Ptu{i} + \bar \gamma _w^i \Ptw{i} \right)}
\newcommand{\Pn}[1]{\,{ {\bf D} }_{#1,{n} } }
\newcommand{\Ptu}[1]{\,{ {\bf D} }_{#1,{u} } }
\newcommand{\Ptw}[1]{\,{ {\bf D} }_{#1,{w} } }


{ \bf {\dot q} }   & =  \underbrace{ { \bf L } }_{\HC{Velocity transformation matrix} }({\bf{q} })\overbrace{ {\bf v} }^{\HC{ Generalized velocities} }   \nonumber \\
{ \underbrace{\bf{M} }_{\text{Mass matrix} } \overbrace{\bf{(q)} }^{\HC{Generalized Positions} } } {\bf{\dot v} } & =\underbrace{\AppliedF}_{\HC{Applied force} } -\overbrace{\ReactF}^{\HC{Reaction force} } +  \sum\limits_{i\in \cA({\bf q},\delta)} \underbrace{\FricConF}_{\text{Frictional contact force} } \nonumber \\
{\bf{0} } &= {\bf{g} }({\bf{q} },t) \nonumber\\
i \in \cA({\bf q}(t),\delta)  &: 0 \le \hatGN{i} \; \perp \; \overbrace{\Phi_{i} }^{\text{Gap function} }({\bf q}) \geq 0  \nonumber \nonumber \\
\left(\hatGU{i}, \hatGW{i} \right)  &=  \mathop {\mbox{argmin} }\limits_{ \sqrt{\left( {\bar \gamma _u^i }\right)^2 + \left({\bar \gamma _w^i }\right)^2}\leq \mu_{i} \hatGN{i} }  \underbrace{\DissipEnergy}_{\text{Friction dissipation energy} } \nonumber
\end{align}
</div>

#### Discretized Impulse-Velocity Form

Here the equations are similar, but the lagrange multipliers become reaction impulses rather than forces. Also stabilization terms are added for both the contacts and the joints that correct for penetrations. The relaxation term can be thought of as a "tilting" function that makes the lagrange multipliers perpendicular to the friction cone. 
<div>
 \begin{align}

\newcommand{\cA}{ {\cal A} }
\newcommand{\HC}[1]{ \rlap{\text{#1} } }
\newcommand{\hatGN}[1]{ {\widehat{\gamma}_{#1,n} } }
\newcommand{\hatGU}[1]{ {\widehat{\gamma}_{#1,u} } }
\newcommand{\hatGW}[1]{ {\widehat{\gamma}_{#1,w} } }
\newcommand{\GN}[1]{ { {\gamma}_{#1,n} } }
\newcommand{\GU}[1]{ { {\gamma}_{#1,u} } }
\newcommand{\GW}[1]{ { {\gamma}_{#1,w} } }

\newcommand{\AppliedF}{ { {\bf{f} }\left( {t,  {\bf q} , {\bf v} } \right)} }
\newcommand{\ReactF}{ { { {\bf{g} }_{\bf q}^{\rm{T} }({ {\bf q} },t){\lambda } } } }
\newcommand{\FricConF}{\left( \hatGN{i}\Pn{i} + \hatGU{i} \Ptu{i}  + \hatGW{i} \Ptw{i}  \right)}
\newcommand{\DissipEnergy}{ {\bf v}^T \left( \bar \gamma _u^i \Ptu{i} + \bar \gamma _w^i \Ptw{i} \right)}
\newcommand{\Pn}[1]{\,{ {\bf D} }_{#1,{n} } }
\newcommand{\Ptu}[1]{\,{ {\bf D} }_{#1,{u} } }
\newcommand{\Ptw}[1]{\,{ {\bf D} }_{#1,{w} } }
\newcommand{\PnT}[1]{\,{ {\bf D}}^T_{#1,{n} } }
\newcommand{\Relaxation}{\mu_i \sqrt{\left(\bf{D}_{i,v}^T \bf{v}^{(l+1)}\right)^2+\left(\bf{D}_{i,w}^T \bf{v}^{(l+1)}\right)^2} }

{\overbrace{ {\bf q}^{(l+1)} }^{\text{Generalized positions} } }  & =  {\bf q}^{(l)} + \overbrace{h}^{\text{Step size} } \underbrace{ {\bf L} }_{\HC{Velocity transformation matrix} } ({\bf q}^{(l)}) {\bf v}^{(l+1)} \nonumber\\
{\bf M}(\overbrace{ {\bf v}^{(l+1)} }^{\HC{Generalized speeds} }-{\bf v}^{(l)}) & =   \underbrace{ {h}{\bf f}({t^{(l)},{ {\bf q}^{(l)} },{ {\bf v}^{(l)} })} }_{\text{Applied impulse} } - \overbrace{ { {\bf{g} }_{\bf q}^{\rm{T} }({ {\bf q}^{(l)} },t){\lambda } }}^{\text{Reaction impulse} }  + \sum_{i \in \cA(q^{(l)},\delta)} \underbrace{\left( \GN{i}\Pn{i} + \GU{i} \Ptu{i}  + \GW{i} \Ptw{i} \right)}_{\text{Frictional contact reaction impulses} }  \nonumber\\
0  & =  \underbrace{\frac{1}{h}{\bf{g} }({ {\bf{q} }^{(l)} },t)}_{\text{Stabilization term} } + { {\bf{g} }_{\bf{q} }}^T{ {\bf{v} }^{(l + 1)} } + { {\bf{g} }_t} \nonumber\\
i \in \cA(q^{(l)},\delta)  &:  0 \leq  \overbrace{\frac{1}{h}\Phi_{i}({\bf q}^{(l)})}^{\text{Stabilization term} } + \PnT{i} {\bf v}^{(l+1)} -\overbrace{\Relaxation}^{ \text{Relaxation Term} } \perp  \GN{i} \geq 0  \nonumber\\
  \left(\GU{i}, \GW{i} \right) &= \mathop {\mbox{argmin} }\limits_{\sqrt{\GU{i}^2 + \GW{i}^2} \leq \mu_{i} \GN{i} } \;\; {\bf v}^T \left( \GU{i} \Ptu{i} + \GW{i} \Ptw{i} \right) \nonumber

\end{align}
</div>

##Dynamics in three ways
I am going to discuss three different models that can be used for solving these equations within GAMS. The first is solving the equations of motion directly using an EMP formulation. The second will solve a quadratic optimization problem with the unknowns being our lagrange multipliers. The third will solve a similar optimization problem where the unknowns are the new velocities. 

####Setting up the basic GAMS model
I am going to assume that GAMS has been installed with a proper license and all of your solvers are in working order. 

This is the basic framework that I will be using for all models. The main idea is to limit as much as possible the information written to disk, using SolveLink=5 keeps gams in memory and makes it run faster. This makes it useful when running GAMS in the loop with a dynamics engine.
Here is common code that is needed for all models 
<pre>
$eolcom #
$offlisting
$Offlog
set constraints(*), contacts(*), dofs(*);
option limrow = 0;
option limcol = 0;
option optcr = 0;
option optca = 0;
option solprint = Silent;
option sysout = off;
option Solvelink = 5;

#These are all of the possible data parameters needed
#Not all are used/loaded for each model
parameter
  h                               "Step Size"
  M(dofs,dofs)                    "Mass Matrix"
  Minv(dofs,dofs)                 "Inverse Mass Matrix"
  D(dofs,constraints)             "Contact Jacobian"
  D_n(dofs,contacts)              "Contact Jacobian Normal"
  D_v(dofs,contacts)              "Contact Jacobian Tangential v"
  D_w(dofs,contacts)              "Contact Jacobian Tangential w"
  f_ext(dofs)                     "External Forces(f) *  h (fh)"
  p_ext(dofs)                     "fh+M*v_l"
  phi_n(contacts)                 "Contact Gap * h"
  mu(contacts)                    "Contact Friction"
  v_l(dofs)                       "Initial Velocity"
  Nshur(constraints,constraints)  "Precomputed Shur Matrix"
  Bshur(constraints)              "Precomputed RHS"
;
</pre>
Here the set constraints represents the total constraints in the system of equation. For example, one contact has three constraints, one normal and two tangential. The set contacts has a one to one mapping with the total number of contacts. The set dofs is a list containing all of the degrees of freedom for the system. Each body has 6 entries and they are organized in a linear fashion, every sixth entry represents a different body. 

####Solving the EOM

<pre>
#COMMON CODE FROM ABOVE GOES HERE

#Load all data from a gdx file
$gdxin data.gdx
$load  constraints contacts dofs
$load  M D f_ext h phi_n mu v_l D_n D_v D_w p_ext Minv
$gdxin

variables v(dofs), energy(contacts), gamma_v(contacts), gamma_w(contacts);
positive variable gamma_n(contacts);
equations 
    NewtonEuler_eq(dofs)         "Newton Euler Equations of Motion"
    DefineGap_eq(contacts)       "Definition of Gap Function"
    Conic_eq(contacts)           "Conic Constraint"
    FrictionEnergy_eq(contacts)  "Friction Energy equation"
;

NewtonEuler_eq(i)..
  sum(j, M(i,j)*(v(j)-v_l(j)))=e= sum(contacts, -D_n(i,contacts)*gamma_n(contacts)-D_v(i,contacts)*gamma_v(contacts)-D_w(i,contacts)*gamma_w(contacts))+f_ext(i);

DefineGap_eq(contacts)..
  phi_n(contacts) + sum(i, -D_n(i,contacts)*v(i))-mu(contacts)*sqrt(sqr(sum(dofs, -D_v(dofs,contacts)*v(dofs)))+sqr(sum(dofs, -D_w(dofs,contacts)*v(dofs))))=g= 0;

Conic_eq(contacts)..
  sqr(gamma_v(contacts)) + sqr(gamma_w(contacts)) =l= sqr(mu(contacts)*gamma_n(contacts));

FrictionEnergy_eq(contacts)..
  energy(contacts) =e=  sum((i), -D_v(i,contacts)*v(i)*gamma_v(contacts))+sum((i), -D_w(i,contacts)*v(i)*gamma_w(contacts));

#Guess value for new velocities is the old velocities
v.l(dofs) = v_l(dofs);
#Create EMP model with all of the defined equations
model frictemp / all /;
#Write out the EMP formulation
file empinfo / '%emp.info%' /;
put empinfo 'equilibrium'/;
put 'vi NewtonEuler_eq v'/;
put 'vi DefineGap_eq gamma_n'/;
loop(contacts,
put 'min ' energy(contacts) /;
put gamma_v(contacts);
put gamma_w(contacts);
put / FrictionEnergy_eq(contacts) Conic_eq(contacts) ;
);
putclose;
#Solve the model
solve frictemp using emp;

#Post Process
parameter delta_v(dofs), iters, time, obj;
obj = frictemp.ObjVal;
iters = frictemp.iterUsd;
time = frictemp.resUsd;
delta_v(dofs) = v.l(dofs);

execute_unload "soln.gdx", delta_v obj iters time;
</pre>

####Solving The Quadratic Optimization Problem (Dual Form)
Here we transform the EOM to the following Cone Complementarity Problem (CCP)
<div>
\begin{align}
\newcommand{\cone}{ {\Upsilon} }
\newcommand{\cA}{ {\cal A} }
\newcommand{\HC}[1]{ \rlap{\text{#1} } }
\newcommand{\hatGN}[1]{ {\widehat{\gamma}_{#1,n} } }
\newcommand{\hatGU}[1]{ {\widehat{\gamma}_{#1,u} } }
\newcommand{\hatGW}[1]{ {\widehat{\gamma}_{#1,w} } }
\newcommand{\GN}[1]{ { {\gamma}_{#1,n} } }
\newcommand{\GU}[1]{ { {\gamma}_{#1,u} } }
\newcommand{\GW}[1]{ { {\gamma}_{#1,w} } }

\newcommand{\AppliedF}{ { {\bf{f} }\left( {t,  {\bf q} , {\bf v} } \right)} }
\newcommand{\ReactF}{ { { {\bf{g} }_{\bf q}^{\rm{T} }({ {\bf q} },t){\lambda } } } }
\newcommand{\Pn}[1]{\,{ {\bf D} }_{#1,{n} } }
\newcommand{\Ptu}[1]{\,{ {\bf D} }_{#1,{u} } }
\newcommand{\Ptw}[1]{\,{ {\bf D} }_{#1,{w} } }
\newcommand{\PnT}[1]{\,{ {\bf D}}^T_{#1,{n} } }
\newcommand{\Relaxation}{\mu_i \sqrt{\left(\bf{D}_{i,v}^T \bf{v}^{(l+1)}\right)^2+\left(\bf{D}_{i,w}^T \bf{v}^{(l+1)}\right)^2} }

\text{Find } \bf{\gamma}_i^{(l+1)}, \text{ for } i=1,\ldots,N_c \nonumber \\
\text{such that } \cone_i \ni \bf{\gamma}_i ^{(l+1)}\perp -\left({\bf{N}}\bf{\gamma}^{(l+1)}+\bf{r}\right)_i \in \cone_i^{\circ}\nonumber \\

\cone_i=\{\left[\GN{i} ,\GU{i} ,\GW{i} \right]^T \in \mathbb{R}^3 | \sqrt{\GU{i} ^2+\GW{i} ^2} \leq \mu_i \GN{i} \} \nonumber \\
\cone_i^\circ=\{\left[\GN{i} ,\GU{i} ,\GW{i}\right]^T \in \mathbb{R}^3 | \GN{i} \leq -\mu_i\sqrt{\GU{i}^2+\GW{i}^2}\} \\\nonumber

\boldsymbol{k}=f h+Mv^{(l)}\\
{\bf{N}} = {\bf{D}}^T{\bf{M}^{-1}}{\bf{D}} \nonumber \\
{\bf{r}} = {\bf{b}}+{\bf{D}}^T{\bf{M}^{-1}}{\boldsymbol{k}} \nonumber \\
\bf{\gamma}=  \left [ \bf{\gamma}^T_1,\bf{\gamma}^T_2,\cdots,\bf{\gamma}^T_{N_c} \right ]^T \in \mathbb{R}^{3N_c}\nonumber 

 \end{align}
</div>
This CCP leads to the following quadratic optimization problem with conic constraints

<div>
\begin{align}
\newcommand{\cone}{ {\Upsilon} }
\newcommand{\cA}{ {\cal A} }
\newcommand{\HC}[1]{ \rlap{\text{#1} } }
\newcommand{\hatGN}[1]{ {\widehat{\gamma}_{#1,n} } }
\newcommand{\hatGU}[1]{ {\widehat{\gamma}_{#1,u} } }
\newcommand{\hatGW}[1]{ {\widehat{\gamma}_{#1,w} } }
\newcommand{\GN}[1]{ { {\gamma}_{#1,n} } }
\newcommand{\GU}[1]{ { {\gamma}_{#1,u} } }
\newcommand{\GW}[1]{ { {\gamma}_{#1,w} } }

\newcommand{\AppliedF}{ { {\bf{f} }\left( {t,  {\bf q} , {\bf v} } \right)} }
\newcommand{\ReactF}{ { { {\bf{g} }_{\bf q}^{\rm{T} }({ {\bf q} },t){\lambda } } } }
\newcommand{\Pn}[1]{\,{ {\bf D} }_{#1,{n} } }
\newcommand{\Ptu}[1]{\,{ {\bf D} }_{#1,{u} } }
\newcommand{\Ptw}[1]{\,{ {\bf D} }_{#1,{w} } }
\newcommand{\PnT}[1]{\,{ {\bf D}}^T_{#1,{n} } }

\min f\left(\bf{\gamma}\right) = \frac{1}{2}\bf{\gamma}^T {\bf{N}} \bf{\gamma}+\bf{r}^T \bf{\gamma}\nonumber\\
\text{subject to } \bf{\gamma}_i \in \cone_i \nonumber \\
\text{ for } i=1,2,\ldots,N_c  \nonumber \\

\end{align}
</div>

This model can be specified in GAMS in the following manner:


<pre>
#COMMON CODE FROM ABOVE GOES HERE
#Set the default modeltype to qcp, can be switched to nlp
$if not set modtype $set modtype qcp
$gdxin data.gdx
$load  constraints contacts dofs 
$load  mu Nshur Bshur p_ext Minv D v_l M g_0 phi_n D_n D_v D_w h
$gdxin

variable gamma(constraints), obj, residual(constraints);
variable gamma_v(contacts), gamma_w(contacts), Dgamma_k(dofs);
positive variable gamma_n(contacts);
equations 
  Objective_eq         "Objective Function"
  Conic_eq(contacts)   "Conic constraint on Gamma"
  gamma_n_eq(contacts) "Transform from gamma to gamma_n"
  gamma_v_eq(contacts) "Transform from gamma to gamma_v"
  gamma_w_eq(contacts) "Transform from gamma to gamma_w"
  Convert_1(dofs)      "Convert between gamma and velocity"
  Convert_2(dofs)      "Convert between gamma and velocity"
;
alias(constraints, i, j, k);
alias(dofs, a, b, c);

variable v(dofs);
Objective_eq..
   obj  =e=  .5*sum(i, gamma(i)*sum(k, Nshur(i,k)*gamma(k)))- sum(i, gamma(i)*Bshur(i));
Conic_eq(contacts)..
	sqr(gamma_v(contacts)) + sqr(gamma_w(contacts)) =l= sqr(gamma_n(contacts));

gamma_n_eq(contacts)..
  gamma_n(contacts) =e= mu(contacts)*sum(constraints$(mod(ord(constraints)+2,3)=0 and ord(contacts) = (ord(constraints)+2)/3), gamma(constraints));

gamma_v_eq(contacts)..
  gamma_v(contacts) =e= sum(constraints$(mod(ord(constraints)+1,3)=0 and ord(contacts) = (ord(constraints)+1)/3), gamma(constraints));

gamma_w_eq(contacts)..
  gamma_w(contacts) =e= sum(constraints$(mod(ord(constraints)+0,3)=0 and ord(contacts) = (ord(constraints)+0)/3), gamma(constraints));  

Convert_1(dofs)..
  Dgamma_k(dofs) =e= p_ext(dofs)+sum(i, -D(dofs,i)*gamma(i));
Convert_2(dofs)..
  v(dofs) =e= sum(a, Minv(dofs,a)*(Dgamma_k(a)));

model fricdual / all/;
solve fricdual using %modtype% min obj;
parameter res, iters, time, delta_v(dofs);
res = 0;
iters = fricdual.iterUsd;
time = fricdual.resUsd;
delta_v(dofs) = v.l(dofs);
execute_unload "soln.gdx", gamma delta_v obj res iters time;
</pre>

Using command line arguments the type of model can be changed between QCP and NLP. Different types of solvers can be used with each type of model.

####Solving The Quadratic Optimization Problem (Primal Form)
This version of the quadratic optimization problem solves for the new velocities
<div>
\begin{align}
\newcommand{\cone}{ {\Upsilon} }
\newcommand{\cA}{ {\cal A} }
\newcommand{\HC}[1]{ \rlap{\text{#1} } }
\newcommand{\hatGN}[1]{ {\widehat{\gamma}_{#1,n} } }
\newcommand{\hatGU}[1]{ {\widehat{\gamma}_{#1,u} } }
\newcommand{\hatGW}[1]{ {\widehat{\gamma}_{#1,w} } }
\newcommand{\GN}[1]{ { {\gamma}_{#1,n} } }
\newcommand{\GU}[1]{ { {\gamma}_{#1,u} } }
\newcommand{\GW}[1]{ { {\gamma}_{#1,w} } }

\newcommand{\AppliedF}{ { {\bf{f} }\left( {t,  {\bf q} , {\bf v} } \right)} }
\newcommand{\ReactF}{ { { {\bf{g} }_{\bf q}^{\rm{T} }({ {\bf q} },t){\lambda } } } }
\newcommand{\Pn}[1]{\,{ {\bf D} }_{#1,{n} } }
\newcommand{\Ptu}[1]{\,{ {\bf D} }_{#1,{u} } }
\newcommand{\Ptw}[1]{\,{ {\bf D} }_{#1,{w} } }
\newcommand{\PnT}[1]{\,{ {\bf D}}^T_{#1,{n} } }

\min f\left(\bf{\gamma}\right) &= \frac{1}{2}\bf{v^{(l+1)} }^T {\bf{M}} \bf{v^{(l+1)} }+\bf{f}^T \bf{v}\nonumber\\
\text{subject to } \Upsilon_i^\circ &\ni \frac{1}{h}\Phi_i+D_{i,n}^T v^{(l+1)} -\mu \sqrt{ {D_{i,v}^Tv^{(l+1)} }^2+{D_{i,w}^T v^{(l+1)} }^2} \\
\text{ for } i&=1,2,\ldots,N_c  \nonumber \\
\end{align}
</div>

<pre>
#COMMON CODE FROM ABOVE GOES HERE
#Set the default modeltype to qcp, can be switched to nlp
$if not set modtype $set modtype qcp
$gdxin data.gdx
$load  constraints contacts dofs
$load  M D f_ext h phi_n mu v_l D_n D_v D_w Minv p_ext
$gdxin

alias(dofs, i, j, k);
alias(dofs,a,b, c);
equations 
Objective_eq           "Objective Function"
DefineGap_eq(contacts) "Definition of Gap Function"
Def_u_v(contacts)      "Transform velocities"
Def_u_w(contacts)      "Transform velocities"
Conic_eq(contacts)     "Conic constraint"
Convert_1(dofs)        "Convert between gamma and velocity"
Convert_2(dofs)        "Convert between gamma and velocity"
;

variable obj, v(dofs),u_v(contacts), u_w(contacts), Dgamma_k(dofs);
positive variable s_un(contacts);
parameter s(contacts);

Objective_eq..
  obj  =e= .5* sum(i, (v(i))*sum(k, M(i,k)*(v(k))))- sum(i, (v(i))*p_ext(i));

DefineGap_eq(contacts)..
  s_un(contacts) =e= phi_n(contacts) + sum(i, -D_n(i,contacts)*v(i))-mu(contacts)*s(contacts);

Def_u_v(contacts)..
  u_v(contacts) =e=  sum((i), -D_v(i,contacts)*v(i));

Def_u_w(contacts)..
  u_w(contacts) =e=  sum((i), -D_w(i,contacts)*v(i));

Conic_eq(contacts)..
   (sqr(u_v(contacts))+sqr(u_w(contacts))) =l=sqr(s_un(contacts)/mu(contacts));

v.l(dofs) = v_l(dofs);

variable gamma_v(contacts), gamma_w(contacts), gamma(constraints);

Convert_1(dofs)..
  Dgamma_k(dofs) =e= p_ext(dofs)+sum(constraints, -D(dofs,constraints)*gamma(constraints));
Convert_2(dofs)..
  v(dofs) =e= sum(a, Minv(dofs,a)*(Dgamma_k(a)));

model fricprimal / all/;
set iter /iter1*iter10/;
loop(iter,
obj.l  = .5* sum(i, (v.l(i))*sum(k, M(i,k)*(v.l(k))))- sum(i, (v.l(i))*p_ext(i));
u_v.l(contacts) =  sum((i), -D_v(i,contacts)*v.l(i));
u_w.l(contacts) =  sum((i), -D_w(i,contacts)*v.l(i));
s(contacts) = sqrt(sqr(u_v.l(contacts))+sqr(u_w.l(contacts)));
s_un.l(contacts) = phi_n(contacts) + sum(i, -D_n(i,contacts)*v.l(i))-mu(contacts)*s(contacts);
solve fricprimal using %modtype% min obj;
);
parameter delta_v(dofs), iters, time;
iters = fricprimal.iterUsd;
time = fricprimal.resUsd;

delta_v(dofs) = v.l(dofs);
execute_unload "soln.gdx", gamma delta_v obj iters time;
</pre>

This model is slightly different than the other two in that it uses an iterative scheme to update the relaxation term. We found that doing 10 iterations was usually enough to converge to a solution.

##Solvers

This table represents the ist of solvers that will be used for each model, the goal is to understand how they perform and if they provide different solutions


| Solver  | Dual qcp | Dual nlp | Primal qcp | Primal nlp | EOM |
|---------|----------|----------|------------|------------|-----|
| Conopt  | YES      | YES      | YES        | YES        | NO  |
| Cplexd  | YES      | NO       | YES        | NO         | NO  |
| Gurobi  | YES      | NO       | YES        | NO         | NO  |
| Ipopt   | YES      | YES      | YES        | YES        | NO  |
| minos   | YES      | YES      | YES        | YES        | NO  |
| knitro  | YES      | YES      | YES        | YES        | NO  |
| lindo   | YES      | NO       | YES        | NO         | NO  |
| pathnlp | NO       | YES      | NO         | YES        | NO  |
| miles   | NO       | YES      | NO         | NO         | YES |
| path    | NO       | YES      | NO         | NO         | YES |
{:.table .table-condensed}

## Models

Here several models will be described and detals provided on the solutions provided by different solvers

#### Box on an inclined plane

Results for normal force and tangential friction force for an angle of 0 degrees. Mass of the block is 1.0 kg

| Solver  | dual qcp    | dual nlp    | primal qcp  | primal nlp  | EOM emp     |
|---------|-------------|-------------|-------------|-------------|-------------|
| Conopt  | 9.81        | 9.81        | 9.81        | 9.81        | 0           |
| Cplexd  | 9.699811889 | 0           | 9.81000067  | 0           | 0           |
| Gurobi  | 10.00146358 | 0           | 9.812432398 | 0           | 0           |
| Ipopt   | 9.81004453  | 9.81004453  | 9.810017486 | 9.810017486 | 0           |
| minos   | 9.810051932 | 9.810051932 | 9.81        | 9.81        | 0           |
| knitro  | 9.812031608 | 9.812031608 | 10.33712774 | 10.33712774 | 0           |
| lindo   | 39.24048097 | 0           | 9.810070548 | 0           | 0           |
| pathnlp | 0           | 9.809653585 | 0           | 9.80965966  | 0           |
| miles   | 0           | 0           | 0           | 0           | 9.81        |
| path    | 0           | 0           | 0           | 0           | 9.809913388 |
{:.table .table-condensed}

| Solver  | dual qcp  | dual nlp  | primal qcp | primal nlp | EOM emp |
|---------|-----------|-----------|------------|------------|---------|
| Conopt  | 0         | 0         | 1.63E-16   | 1.63E-16   | 0       |
| Cplexd  | 9.15E-12  | 0         | 3.68E-20   | 0          | 0       |
| Gurobi  | 4.82E-11  | 0         | -2.35E-16  | 0          | 0       |
| Ipopt   | -2.03E-16 | -2.03E-16 | -6.94E-07  | -6.94E-07  | 0       |
| minos   | 0         | 0         | 0          | 0          | 0       |
| knitro  | -2.44E-16 | -2.44E-16 | -1.18E-17  | -1.18E-17  | 0       |
| lindo   | 6.36E-14  | 0         | 1.21E-19   | 0          | 0       |
| pathnlp | 0         | 0         | 0          | 0          | 0       |
| miles   | 0         | 0         | 0          | 0          | 0       |
| path    | 0         | 0         | 0          | 0          | 0       |
{:.table .table-condensed}

Results for normal force and tangential friction force for an angle of 25 degrees. Mass of the block is 1.0 kg

| Solver  | dual qcp    | dual nlp    | primal qcp  | primal nlp  | EOM emp     |
|---------|-------------|-------------|-------------|-------------|-------------|
| Conopt  | 8.890880015 | 8.890880015 | 8.903193995 | 8.903193995 | 0           |
| Cplexd  | 8.887833911 | 0           | 8.890880643 | 0           | 0           |
| Gurobi  | 8.516675409 | 0           | 8.943110478 | 0           | 0           |
| Ipopt   | 8.890897594 | 8.890897594 | 8.900874991 | 8.900874991 | 0           |
| minos   | 8.890898214 | 8.890898214 | 8.891385779 | 8.891385779 | 0           |
| knitro  | 8.890953799 | 8.890953799 | 9.988990071 | 9.988990071 | 0           |
| lindo   | 35.56570555 | 0           | 8.891402252 | 0           | 0           |
| pathnlp | 0           | 8.890879976 | 0           | 8.890982302 | 0           |
| miles   | 0           | 0           | 0           | 0           | 8.890880015 |
| path    | 0           | 0           | 0           | 0           | 8.890880079 |
{:.table .table-condensed}


| Solver  | dual qcp    | dual nlp    | primal qcp  | primal nlp  | EOM emp     |
|---------|-------------|-------------|-------------|-------------|-------------|
| Conopt  | 4.145881897 | 4.145881897 | 4.141172311 | 4.141172311 | 0           |
| Cplexd  | 4.146100806 | 0           | 4.145881789 | 0           | 0           |
| Gurobi  | 4.346501223 | 0           | 4.120027138 | 0           | 0           |
| Ipopt   | 4.145873977 | 4.145873977 | 4.135891029 | 4.135891029 | 0           |
| minos   | 4.146010481 | 4.146010481 | 4.145469386 | 4.145469386 | 0           |
| knitro  | 4.145843537 | 4.145843537 | 3.742626642 | 3.742626642 | 0           |
| lindo   | 16.5822553  | 0           | 4.145673861 | 0           | 0           |
| pathnlp | 0           | 4.145881917 | 0           | 4.145831445 | 0           |
| miles   | 0           | 0           | 0           | 0           | 4.145881897 |
| path    | 0           | 0           | 0           | 0           | 4.145881833 |
{:.table .table-condensed}

####More Models to Come

