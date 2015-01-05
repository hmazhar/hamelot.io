---
layout: post
title: Compiling PhysBAM using clang
date: '2015-01-05'
description: Documenting the process of getting PhysBAM to compile using clang on OSX 10.10
categories: [programming]
tags: [programming, c++, clang, osx]
---

The purpose of this post is to document the process I went through to compile the public PhysBAM library using clang. With clang support XCode should also compile the code properly.

####Setup
{% highlight bash %}
Repository:  https://github.com/hmazhar/physbam_public

OS:  OSX 10.10.1

Compiler:
Apple LLVM version 6.0 (clang-600.0.56) (based on LLVM 3.5svn)
Target: x86_64-apple-darwin14.0.0
Thread model: posix
{% endhighlight %}

####Overview

Most of the compilation errors were not unique and came up quite often. The most prevalent errors were related to the following.

* Missing functions  - Usually defined after use, Fix is to move them before use or create prototypes at the top of the file
* Two Phase name lookup - This error manifests itself as the following:

{% highlight bash %}
error: call to function 'Foo'
      that is neither visible in the template definition nor found by argument-dependent lookup
{% endhighlight %}

The problem is caused by the function, in this case "Foo" being defined in the base class of the templated child class. 
There are two ways to fix this error, first as documented [here](http://blog.llvm.org/2009/12/dreaded-two-phase-name-lookup.html) is to add a this-> before any functions that are defined in the base class. The alternative is to explicitly scope the function with the child class. Both seem to work just fine, I thought that the first method, using this->, is a little bit cleaner. 

Other errors exist but were not common, they will be covered here on a case by case basis.




####Using this-> inside of a static function

{% highlight bash %}
PhysBAM_Tools/Arrays/ARRAY_BASE.h:258:20: error: call to non-static member function without an object argument
{T_ARRAY& self=Derived();self(to)=self(from);}
{% endhighlight %}

The issue is with the use of Derived()
The relevant code:

{% highlight c++ %}
T_ARRAY& Derived()
{return static_cast<T_ARRAY&>(*this);}

const T_ARRAY& Derived() const
{return static_cast<const T_ARRAY&>(*this);}

...

static void Copy_Element(const ID from,const ID to)
{T_ARRAY& self=Derived();self(to)=self(from);}

template<class T_ARRAY1>
static void Copy_Element(const T_ARRAY1& from_array,const ID from,const ID to)
{T_ARRAY& self=Derived();self(to)=static_cast<const T_ARRAY&>(from_array)(from);}

{% endhighlight %}

Derived needs to use a pointer to the current object, wile Copy_Element is a static function, this is not possible so copy_element needs to be made into a non-static function.


####Function definition after use

Error:
{% highlight bash %}
PhysBAM_Tools/Math_Tools/Hash.h:84:19: error: call to function 'Hash_Reduce' that is neither visible in the template definition nor found by argument-dependent lookup
{return Value(Hash_Reduce(key));}
{% endhighlight %}

The problem is that the definition for the Hash_Reduce function appears after the use of the same function, the fix is simple, add a function prototype at the top of the file

{% highlight c++ %}
//#####################################################################
// Define Hash_Reduce
//#####################################################################
inline int Hash_Reduce(const bool key);
inline int Hash_Reduce(const char key);
inline int Hash_Reduce(const unsigned char key);
inline int Hash_Reduce(const short key);
inline int Hash_Reduce(const unsigned short key);
inline int Hash_Reduce(const int key);
inline int Hash_Reduce(const unsigned int key);
{% endhighlight %}

Error:
{% highlight bash %}
PhysBAM_Tools/Parallel_Computation/THREADED_UNIFORM_GRID.cpp:71:5: error: call to function 'Fill_Process_Ranks' that is neither visible in the template definition nor found by argument-dependent lookup
    Fill_Process_Ranks(process_grid,process_ranks,axes);
{% endhighlight %}

The fix is to move the definitions of Fill_Process_Ranks to the top of the file.

Error:
{% highlight bash %}
PhysBAM_Geometry/Grids_Uniform_Computations/LEVELSET_MAKER_UNIFORM.cpp:114:77: error: call to function 'Process_Segment' that is neither visible in the template definition nor found by argument-dependent lookup
        for(int j=1;j<=grid.counts.y;j++) for(int k=1;k<=grid.counts.z;k++) Process_Segment(grid.counts.x,edge_is_blocked_x,is_inside,TV_INT(1,j,k),1,vote);
{% endhighlight %}

The fix is to move the Process_Segment function definition to the top of the file.

####Two Phase name lookup issue

The fix for these errors, as mentioned earlier is to add a this-> before the undeclared function

{% highlight bash %}
PhysBAM_Tools/Grids_Uniform_Advection/ADVECTION_CONSERVATIVE_ENO.cpp:56:22: error: use of undeclared identifier 'ENO'
        T2 flux_left=ENO(dx,DUZ1(i)+alpha*DZ1(i),DUZ2(i-1)+alpha*DZ2(i-1),DUZ2(i)+alpha*DZ2(i));


PhysBAM_Tools/Grids_Uniform_Advection/ADVECTION_HAMILTON_JACOBI_ENO.cpp:30:79: error: use of undeclared identifier 'ENO'
    else if(order == 2) for(i=m_start;i<=m_end;i++){if(u(i) > 0) u_Zx(i)=u(i)*ENO(dx,D1(i-1),D2(i-2),D2(i-1));else u_Zx(i)=u(i)*ENO(dx,D1(i),-D2(i),...

PhysBAM_Tools/Grids_Uniform_Boundaries/BOUNDARY_MAC_GRID_PERIODIC.cpp:21:35: error: use of undeclared identifier 'Find_Ghost_Regions'
    ARRAY<RANGE<TV_INT> > regions;Find_Ghost_Regions(grid,regions,number_of_ghost_cells);


PhysBAM_Tools/Grids_Uniform_Advection/ADVECTION_HAMILTON_JACOBI_ENO.cpp:30:79: error: use of undeclared identifier 'ENO'
    else if(order == 2) for(i=m_start;i<=m_end;i++){if(u(i) > 0) u_Zx(i)=u(i)*ENO(dx,D1(i-1),D2(i-2),D2(i-1));else u_Zx(i)=u(i)*ENO(dx,D1(i),-D2(i),-D2(i-1));}


PhysBAM_Tools/Grids_Uniform_Boundaries/BOUNDARY_REFLECTION_ATTENUATION.cpp:28:38: error: use of undeclared identifier 'Boundary'
    int axis=(side+1)/2,boundary=Boundary(side,region);

PhysBAM_Tools/Grids_Uniform_Advection/ADVECTION_HAMILTON_JACOBI_WENO.cpp:24:35: error: use of undeclared identifier 'WENO'
        if(u(i) > 0) u_Zx(i)=u(i)*WENO(D1(i-3),D1(i-2),D1(i-1),D1(i),D1(i+1),epsilon);

PhysBAM_Tools/Grids_Uniform_PDE_Linear/POISSON_UNIFORM.cpp:59:37: error: use of undeclared identifier 'psi_D'
                            else if(psi_D(cell_index-offset)) b(matrix_index)-=element*u(cell_index-offset);

PhysBAM_Tools/Grids_Uniform_PDE_Linear/POISSON_UNIFORM.cpp:47:162: error: use of undeclared identifier 'f'
                SPARSE_MATRIX_FLAT_NXN<T>& A=A_array(filled_region_colors(cell_index));VECTOR_ND<T>& b=b_array(filled_region_colors(cell_index));b(matrix_index)=f(cell_index);

PhysBAM_Tools/Grids_Uniform_PDE_Linear/POISSON_UNIFORM.cpp:70:94: error: use of undeclared identifier 'u'
                            else if(this->psi_D(cell_index+offset)) b(matrix_index)-=element*u(cell_index+offset);               

PhysBAM_Tools/Grids_Uniform_PDE_Linear/LAPLACE_UNIFORM.cpp:174:5: error: use of undeclared identifier 'Find_Tolerance'
    Find_Tolerance(b); // needs to happen after b is completely set up

PhysBAM_Tools/Parallel_Computation/THREADED_UNIFORM_GRID.cpp:61:5: error: use of undeclared identifier 'Split_Grid'
    Split_Grid(processes_per_dimension);

PhysBAM_Geometry/Basic_Geometry/BOX.cpp:26:9: error: use of undeclared identifier 'Lazy_Inside'
    if(!Lazy_Inside(X)) return clamp(X,min_corner,max_corner);

PhysBAM_Geometry/Implicit_Objects/IMPLICIT_OBJECT_TRANSFORMED.h:219:85: error: use of undeclared identifier 'Object_Space_Point'
        VECTOR<T,d-1> curvatures=object_space_implicit_object->Principal_Curvatures(Object_Space_Point(X));

PhysBAM_Geometry/Spatial_Acceleration/TRIANGLE_HIERARCHY.h:61:88: error: use of undeclared identifier 'Thicken_Leaf_Boxes'
    {Calculate_Bounding_Boxes(box_hierarchy,start_frame,end_frame);if(extra_thickness) Thicken_Leaf_Boxes(extra_thickness);}

PhysBAM_Geometry/Grids_Uniform_Level_Sets/LEVELSET_2D.h:36:30: error: use of undeclared identifier 'Phi'
    else return VECTOR<T,2>((Phi(VECTOR<T,2>(location.x+grid.dX.x,location.y))-Phi(VECTOR<T,2>(location.x-grid.dX.x,location.y)))/(2*grid.dX.x),

PhysBAM_Geometry/Grids_Uniform_Collisions/GRID_BASED_COLLISION_GEOMETRY_UNIFORM.h:95:12: error: use of undeclared identifier 'Latest_Crossover'
    return Latest_Crossover(X,X,dt,body_id,aggregate_id,initial_hit_point);}

PhysBAM_Geometry/Grids_Uniform_Collisions/GRID_BASED_COLLISION_GEOMETRY_UNIFORM.h:125:13: error: use of undeclared identifier 'Any_Simplex_Crossover'
    {return Any_Simplex_Crossover(start_X,end_X,dt);} // TODO: use object ids

PhysBAM_Geometry/Grids_Uniform_Collisions/GRID_BASED_COLLISION_GEOMETRY_UNIFORM.cpp:100:12: error: use of undeclared identifier 'Intersection_With_Any_Simplicial_Object'/Users/hammad/repos/physbam_public/PhysBAM_Geometry/Grids_Uniform_Computations/LEVELSET_MAKER_UNIFORM.cpp:65
        if(Intersection_With_Any_Simplicial_Object(ray,body_id,&objects)){count++;

PhysBAM_Geometry/Grids_Uniform_Computations/LEVELSET_MAKER_UNIFORM.cpp:65:40: error: use of undeclared identifier 'Surface_Thickness_Over_Two'
    const T surface_thickness_over_two=Surface_Thickness_Over_Two(grid),surface_padding_for_flood_fill=Surface_Padding_For_Flood_Fill(grid);

PhysBAM_Geometry/Grids_Uniform_Level_Sets/EXTRAPOLATION_UNIFORM.cpp:59:22: error: use of undeclared identifier 'Remove_Root_From_Heap'
    TV_INT index=Remove_Root_From_Heap(phi_ghost,heap,heap_length,close);

PhysBAM_Geometry/Grids_Uniform_Level_Sets/LEVELSET_MULTIPLE_UNIFORM.cpp:53:34: error: use of undeclared identifier 'Inside_Region'
            if(!positive_regions(Inside_Region(iterator.Cell_Index()))) colors(iterator.Cell_Index())=-1;}

PhysBAM_Geometry/Grids_Uniform_Level_Sets/LEVELSET_1D.h:41:30: error: use of undeclared identifier 'Extended_Phi'
    else return VECTOR<T,1>((Extended_Phi(location+grid.dX)-Extended_Phi(location-grid.dX))/(2*grid.dX.x)).Normalized();}

PhysBAM_Geometry/Grids_Uniform_Computations/LEVELSET_MAKER_UNIFORM.cpp:65:110: error: use of undeclared identifier 'Surface_Padding_For_Flood_Fill'
    const T surface_thickness_over_two=this->Surface_Thickness_Over_Two(grid),surface_padding_for_flood_fill=Surface_Padding_For_Flood_Fill(grid);

PhysBAM_Geometry/Spatial_Acceleration/PARTICLE_HIERARCHY.cpp:41:32: error: use of undeclared identifier 'Initialize_Hierarchy_Using_KD_Tree_Helper'
    children.Remove_All();root=Initialize_Hierarchy_Using_KD_Tree_Helper(kd_tree.root_node);

PhysBAM_Geometry/Spatial_Acceleration/TRIANGLE_HIERARCHY_2D.cpp:21:10: error: use of undeclared identifier 'Initialize_Hierarchy_Using_KD_Tree_Helper'
    root=Initialize_Hierarchy_Using_KD_Tree_Helper(kd_tree.root_node);assert(root==2*leaves-1);

PhysBAM_Rendering/PhysBAM_Ray_Tracing/Rendering_Objects/RENDERING_VOXELS.h:45:24: error: use of undeclared identifier 'Object_Space_Point'
    {return box.Inside(Object_Space_Point(location),small_number);}

{% endhighlight %}


####Missing include

In this case the function is defined in a header which was not included in the file

{% highlight bash %}
PhysBAM_Tools/Grids_Uniform_Interpolation/LINEAR_INTERPOLATION_MAC_1D_HELPER.h:99:37: error: call to function 'Componentwise_Min' that is neither visible in the template definition nor found by argument-dependent lookup
    {if(DX.x<.5) return VECTOR<T,2>(Componentwise_Min(block.Face_X_Value(u_min,0),block.Face_X_Value(u_min,1)),Componentwise_Max(block.Face_X_Value(u_max,0),block.Face_X_Value(u_max,1)));

{% endhighlight %}

fix: add  #include <PhysBAM_Tools/Math_Tools/Componentwise_Min_Max.h> to LINEAR_INTERPOLATION_MAC_1D_HELPER.h

{% highlight bash %}
PhysBAM_Tools/Vectors/VECTOR_BASE.h:101:90: error: call to function 'sqr' that is neither visible in the template definition nor found by argument-dependent lookup
    {Static_Assert_Not_Small();T norm_squared=0;for(int i=1;i<=Size();i++) norm_squared+=sqr((*this)(i));return norm_squared;}
{% endhighlight %}

fix: add #include <PhysBAM_Tools/Math_Tools/sqr.h> to VECTOR_BASE.h

{% highlight bash %}
PhysBAM_Geometry/Rasterization/RIGID_GEOMETRY_RASTERIZATION_HELPER.h:57:13: error: call to function 'Rasterize_Box' that is neither visible in the template definition nor found by argument-dependent lookup
            Rasterize_Box(grid,objects,box,id);}
{% endhighlight %}

fix: add  #include <PhysBAM_Geometry/Grids_Uniform_Computations/RIGID_GEOMETRY_RASTERIZATION_UNIFORM.h> in the RIGID_GEOMETRY_RASTERIZATION_HELPER.cpp file

{% highlight bash %}
PhysBAM_Rendering/PhysBAM_Ray_Tracing/Rendering_Objects/RENDERING_LEVELSET_MULTIPLE_REGION_OBJECT.h:35:136: error: 
      implicit instantiation of undefined template 'PhysBAM::FAST_LEVELSET<PhysBAM::GRID<PhysBAM::VECTOR<float, 3> > >'
    if(aggregate != -1) return BOX<TV>(levelset_multiple.grid.domain).Normal(aggregate);else return levelset_multiple.levelsets(region)->Normal(location);}
{% endhighlight %}

fix: add  #include <PhysBAM_Geometry/Grids_Uniform_Level_Sets/FAST_LEVELSET.h> in the RENDERING_LEVELSET_MULTIPLE_REGION_OBJECT.h file

####Partial ordering of function templates

The error:
{% highlight bash %}
PhysBAM_Tools/Matrices/SPARSE_MATRIX_FLAT_NXN.cpp:428:24: error: partial ordering for explicit instantiation of 'operator<<' is ambiguous
template std::ostream& operator<<(std::ostream&,const SPARSE_MATRIX_FLAT_NXN<float>&);
{% endhighlight %}


This error has me a bit puzzled. the file 
PhysBAM_Tools/Matrices/SPARSE_MATRIX_FLAT_NXN.h contains a definition of operator<<

{% highlight c++ %}
template<class T> inline std::ostream& operator<<(std::ostream& output_stream,const SPARSE_MATRIX_FLAT_NXN<T>& A)
{for(int i=1;i<=A.n;i++){
    for(int j=1;j<=A.n;j++)output_stream<<(A.Element_Present(i,j)?A(i,j):0)<<" ";
    output_stream<<std::endl;} return output_stream;}

{% endhighlight %}

while the PhysBAM_Tools/Matrices/SPARSE_MATRIX_FLAT_NXN.cpp has the following

{% highlight c++ %}
//#####################################################################
// Function operator<<
//#####################################################################
template<class T> std::ostream&
operator<<(std::ostream& output_stream,const SPARSE_MATRIX_FLAT_NXN<T>& A)
{for(int i=1;i<=A.n;i++){
    for(int j=1;j<=A.n;j++)output_stream<<(A.Element_Present(i,j)?A(i,j):0)<<" ";
    output_stream<<std::endl;} return output_stream;}
//#####################################################################
template class SPARSE_MATRIX_FLAT_NXN<float>;
template std::ostream& operator<<(std::ostream&,const SPARSE_MATRIX_FLAT_NXN<float>&);
#ifndef COMPILE_WITHOUT_DOUBLE_SUPPORT
template class SPARSE_MATRIX_FLAT_NXN<double>;
template std::ostream& operator<<(std::ostream&,const SPARSE_MATRIX_FLAT_NXN<double>&);
#endif
{% endhighlight %}


The fix I went with was commenting out the code in PhysBAM_Tools/Matrices/SPARSE_MATRIX_FLAT_NXN.cpp and leaving the identical definition in PhysBAM_Tools/Matrices/SPARSE_MATRIX_FLAT_NXN.h. I will revisit this if it becomes an issue.


Once these errors have been fixed PhysBAM should compile using clang




