---
layout: post
title: Personal Slurm Reference
date: '2015-10-18'
description: Small useful code snippets for using Slurm
categories: other
tags: [slurm]
---

Slurm reference and useful things for running jobs on the labs cluster. Might be useful for other people, posting here for future reference. 

####Base slurm batch file

{% highlight bash %}
#!/bin/bash
#SBATCH -N 1                      # This requests one node
#SBATCH -n 8                      # Request 8 cores on a node
#SBATCH -t 0-10:00                # Walltime days-hours:minutes
#SBATCH --job-name=job_name       # Name of the job
#SBATCH --array=0-100             # Array job with 100 tasks
cd $SLURM_SUBMIT_DIR              # Change directory to the one where the script was executed
./ThingToRun $SLURM_ARRAY_TASK_ID # Executable that will be run for this job
{% endhighlight %}



####Dump stdout and stderr to /dev/null

Often times for large jobs with lots of output its not worth it to keep the programs output if everything is working properly.

{% highlight bash %}
#SBATCH -o /dev/null        # Dump std out to null device
#SBATCH -e /dev/null        # Dump std err to null device
{% endhighlight %}

####Generate data in RAM drive

Each node has a /dev/shm folder where temporary data can be stored really quickly as it is in memory and no disk i/o needs to be performed. 

{% highlight bash %}
# Create folder in RAM drive
mkdir -p /dev/shm/$SLURM_JOBID/
# Run code that will convert data stored on disk to a differnt format, store this data in memory
./convert input_$SLURM_ARRAY_TASK_ID.dat /dev/shm/$SLURM_JOBID/output_$SLURM_ARRAY_TASK_ID.dat
# Do something with the data in the RAM drive
./doStuff /dev/shm/$SLURM_JOBID/output_$SLURM_ARRAY_TASK_ID.dat
# IMPORTANT, delete the folder in memory when done
rm -rf /dev/shm/$SLURM_JOBID
{% endhighlight %}

If a job is canceled then the folder will remain in memory, run the following script to force a cleanup. Always use rm -rf with caution. 

{% highlight bash %}
#!/bin/bash
array=(node1 node2 node3 node4)
for i in "${array[@]}"
do
  ssh $i 'rm -rf /dev/shm/*'    #Remove all files in /dev/shm/ that you have write access to
  echo $i
done
{% endhighlight %}

####Only perform tasks for missing files
Sometimes when performing large jobs, some of the tasks can fail. If the user onyl wants to run a job for the missing files the following pattern can be used

{% highlight bash %}
#If the image does not exist then execute 
if [ ! -f output/$SLURM_ARRAY_TASK_ID.png ]; then
#perform task
./RenderImage $SLURM_ARRAY_TASK_ID
fi
done
{% endhighlight %}

#### Problems with modules not being loaded properly

If a specific module needs to be loaded, add the following to the list of tasks run by the job. 

{% highlight bash %}
module load modulename/version
{% endhighlight %}

#### Request a specific GPU resource

The gres argument can be used to request a specific type of resource

{% highlight bash %}
#SBATCH --gres=gpu:titanx:1   # Request one titanx
{% endhighlight %}

#### Reservations

To view all reservations on the cluster

{% highlight bash %}
scontrol show res
{% endhighlight %}

Run a job using your reservation, note that this will only run on your reservation and none of the other nodes. 

{% highlight bash %}
sbatch --reservation=RESERVATION_NAME slurm_job.sh
{% endhighlight %}
