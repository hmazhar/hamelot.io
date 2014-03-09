---
title: The importance of Node Interleaving on AMD compute nodes  
date: '2014-3-4'
description: Optimal Bios configuration for Supermicro HBQGL-6F/HBQGL-IF
categories: [programming]
tags: [bios, amd, programming]
---

Enabling Node Interleaving in the bios can greatly increase performance of a compute node. Node interleaving essentially lets the CPU decide where to put the memory, disabling it means that the user must explicitly tell where in memory to put data so that the associated CPU gets best performance. 

An explanation of Node Interleaving can be found [here](http://frankdenneman.nl/2010/12/28/node-interleaving-enable-or-disable/)

The end result, a 4-5x performance increase in terms of memory bandwidth. 




In our lab we have several 64 core AMD nodes with the following specs:

- Supermicro HBQGL-6F/HBQGL-IF
- Supermicro 1042-LTF SuperServer

| Processor          | AMD 6274    |
|-------------------:|------------:|
| Nickname           | Interlagos  |
| Clock (GHz)        | 2.2         |
| Sockets/Node       | 4           |
| Cores/Socket       | 16          |
| NUMA/Socket        | 2           |
| DP GFlops/Socket   | 140.8       |
| Memory/Socket      | 32 GB       |
| Bandwidth/Socket   | 102.4 GB/s  |
| DDR3               | 1333 MHz    |
| L1 cache (excl.)   | 16KB        |
| L2 cache/# cores   | 2MB/2       |
| L3 cache/# cores   | 8MB/8       |
{:.table}


I noticed a a few days ago that one of the nodes was performing horribly compared to the other so I decided to do some digging. I installed AMDAPPSDK on both machines and ran the clpeak benchmark with the following results:

Bad Compute Node:

~~~

Platform: AMD Accelerated Parallel Processing
  Device: AMD Opteron(TM) Processor 6274                 
    Driver version  : 1214.3 (sse2,avx,fma4) (Linux x64)
    Compute units   : 64
    Clock frequency : 2200 MHz

    Global memory bandwidth (GBPS)
      float   : 9.22
      float2  : 9.64
      float4  : 9.95
      float8  : 10.16
      float16 : 9.99

  	...

~~~



Good Compute Node:

~~~

Platform: AMD Accelerated Parallel Processing
  Device: AMD Opteron(TM) Processor 6274                 
    Driver version  : 1214.3 (sse2,avx,fma4) (Linux x64)
    Compute units   : 64
    Clock frequency : 2205 MHz

    Global memory bandwidth (GBPS)
      float   : 37.66
      float2  : 42.27
      float4  : 58.08
      float8  : 55.39
      float16 : 43.31

	...

~~~

There is a 4-5x differerence in memory bandwidth!
I omitted the Flop rates of both nodes as they were identical. 
By enabling Node interleaving, the performance increases dramatically. 


### Bios Configuration

Note that I will be talking about Bios version 2.0 here.

I am going to provide the bios configuration of the faster machine for the CPU and the Memory options

Bios->Advanced->Processor & Clock Options

~~~

GART Error [Disabled]
Microcode Update [Enabled]
Secure Virtual Machine Mode [Disabled]
PowerNow [Enabled]
C State Mode [Disabled]
PowerCap [P-state 0]
HPC Mode [Disabled]
CPB Mode [Auto]
CPU DownCore Mode [Disabled]
C1E Support [Auto]
Clock Spread Spectrum [Disabled]

~~~

Bios->Advanced->Advanced Chipset Control -> NorthBridge Configuration

~~~

HT Speed Support [Auto]
IOMMU [Enabled]

~~~

Bios->Advanced->Advanced Chipset Control -> NorthBridge Configuration ->Memory Configuration

~~~

Bank Interleaving [Auto]
Node Interleaving [Auto]		THE MOST IMPORTANT CHANGE
Channel Interleaving [Auto]
CS Sparing Enable [Disabled]
Bank Swizzle Mode [Enabled]

~~~






