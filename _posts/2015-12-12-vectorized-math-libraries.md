---
layout: post
title: Vectorized Math Libraries
date: '2015-12-12'
description: A reference of available vectorized math libraries
categories: programming
tags: [math, SSE, SIMD]
---

A list of vectorized math libraries I found so far, documenting here for future reference

| Name                                                                                                     | License      | Hardware Targets                          |
|----------------------------------------------------------------------------------------------------------|--------------|-------------------------------------------|
| [VCL](http://www.agner.org/optimize/)                                                                    | GPLv3        | SSE*, AVX, AVX2, AVX-512, FMA3, FMA4, XOP |
| [VOLK](http://libvolk.org/)                                                                              | GPLv3        | SSE*, AVX, NEON                           |
| [Vc](https://compeng.uni-frankfurt.de/index.php?id=vc)                                                   | LGPLv3       | SSE*, AVX                                 |
| [libsimdpp](https://github.com/p12tic/libsimdpp/wiki)                                                    | Boost        | SSE2+, AVX, AVX2, FMA, AVX-512, NEON      |
| [Yeppp!](http://www.yeppp.info/)                                                                         | BSD3         | SSE*, AVX, AVX2, FMA, NEON, NEONv2        |
| [Ne10](http://projectne10.github.io/Ne10/)                                                               | BSD3         | NEON                                      |
| [Vector math library](https://github.com/erwincoumans/sce_vectormath)                                    | BSD3         | SSE2, PPU, SPU                            |
| [SIMD Vector Library and Numerical Kernels](http://pages.cs.wisc.edu/~nmitchel/project_pages/gridiron/)  | FreeBSD      | SSE*, AVX, MIC, NEON                      |
| [vectorial](https://github.com/scoopr/vectorial)                                                         | BSD2         | SSE, NEON                                 |
| [vecmathlib](https://bitbucket.org/eschnett/vecmathlib/wiki/Home)                                        | MIT          | SSE, AVX, MIC, NEON, VSX, QPX             |
| [GLM](http://glm.g-truc.net)                                                                             | MIT          | SSE2+, AVX,                               |
| [Libm](http://developer.amd.com/tools-and-sdks/cpu-development/libm/)                                    | AMD          | AVX, FMA3, FMA4, XOP                      |
| [Intel IPP](https://software.intel.com/en-us/intel-ipp)                                                  | proprietary  | SSE*, AVX, AVX2, AVX-512                  |
| [Sleef](http://shibatch.sourceforge.net/)                                                                | None         | SSE2+, AVX, AVX2, FMA4, NEON              |
| [eigen3](http://eigen.tuxfamily.org)                                                                     | MPL2         | SSE*, AVX, FMA, VSX, NEON                 |
{:.table .table-condensed}



References Used:

 - [libvolk](http://libvolk.org/comparisons.html)
 - [simdifying-multi-platform-math](http://blog.molecular-matters.com/2011/10/18/simdifying-multi-platform-math/)
 - [simd-math-libraries-for-sse-and-avx](http://stackoverflow.com/questions/15723995/simd-math-libraries-for-sse-and-avx)
 - [good-portable-simd-library](http://stackoverflow.com/questions/981787/good-portable-simd-library)
 - [Vectorising code to take advantage of modern CPUs (AVX and SSE)](http://www.walkingrandomly.com/?p=3378)