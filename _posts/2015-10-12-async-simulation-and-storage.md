---
layout: post
title: Asynchronous Simulation And Storage
date: '2015-10-12'
description: Simulate and write simulation data to disk at the same time
categories: programming
tags: [programming, c++]
---


This post is about solving a problem that has always been at the back of my mind: How can I speed up my simulations when I have large amounts of File I/O to perform. In many cases I have to write simulation data at 60 FPS for rendering purposes and it can take many seconds to compress and write out a large set of data while it only takes a second or two to simulate. 

In this post I will show a simple snippet of code that builds upon an earlier [post](/programming/compression-of-simulation-data-using-zlib/) about using gzwrite to compress data. 


The key idea is this: Once a simulation step has completed, In a separate thread synchronously copy data into a secondary array and once copied, continue simulation. This second thread compresses and writes data; if a new simulation data file needs to be written another thread will be spawned. Threads will continue spawning if needed until the max threadpool size is reached after which they will all be joined. 

Thanks to [Andrew Seidl](https://andrewseidl.com/) for his help with figuring this out! 

{% highlight c++ %}
//Use std::vector as our global thread pool
std::vector<std::thread> threads;

//Function that writes data to a file
void WriteThreadData(const std::string &&filename,                  //Use move semantics to move filename
                     const std::vector<float> &&simulation_data   //Use move semantics to move data
                    ) {
    // Use your favorite method to write data to a file
    // I use gzwrite to compress the data before writing to save space
}

//This is the maximum number of threads that can be writing at a certain time
#define THREADPOOLSIZE 8

//Function that launches threads to write data
void WriteSimulationData(Simulator *sim, std::string filename) {
    std::vector<float> simulation_data;

    // Copy data to temporary location
    sim->GetData(simulation_data);

    // Create a new thread in our list, move copy the data to the thread
    threads.push_back(std::thread(WriteThreadData, std::move(filename), std::move(simulation_data)));

    // If we have more threads than the threadpool size, join all threads and
    // wait for them to terminate.
    if (threads.size() > THREADPOOLSIZE) {
      for (std::thread &t : threads) {
        t.join();
      }
      // Reset thread pool
      threads.clear();
    }
}

//Finish Threads should be run before program exit to make sure that all running threads have been closed. 
void FinishThreads() {
    for (std::thread &t : threads) {
        t.join();
    }
    threads.clear();
}

{% endhighlight %}