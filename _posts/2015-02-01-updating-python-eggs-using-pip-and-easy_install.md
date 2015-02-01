---
layout: post
title: Updating python eggs using pip and easy_install
date: '2015-02-01'
description: Update your python eggs using pip and easy_install
categories: programming
tags: [python]
---


I use [buildbot](http://buildbot.net/) to manage our labs build/testing infrastructure. I wrote up a [guide](http://hamelot.co.uk/programming/automated-building-of-chrono-via-buildbot/) a while back on how to set it up on different platforms. In this post I wanted to document how to keep the setup updated. 

Note: If using a sandbox first source that sandbox

{% highlight bash %}
source sandbox/bin/activate
{% endhighlight %}

###Update using pip

 - [Reference](http://stackoverflow.com/questions/2720014/upgrading-all-packages-with-pip)

Using a shell command

{% highlight bash %}
pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U
{% endhighlight %}

Using a python file

{% highlight python %}
import pip
from subprocess import call

for dist in pip.get_installed_distributions():
    call("pip install --upgrade " + dist.project_name, shell=True)
{% endhighlight %}



###Update using easy_install

 - [Reference](http://pyinsci.blogspot.com/2007/07/updating-all-your-eggs.html)
 - [Code](http://snipplr.com/view/56085/update-all-easyinstall-python-eggs/)

Using a python file

{% highlight python %}
#!/usr/bin/env python
from setuptools.command.easy_install import main as install
from pkg_resources import Environment, working_set
import sys

#Packages managed by setuptools
plist = [dist.key for dist in working_set]

def autoUp():
    for p in Environment():
        try:
            install(['-U', '-v']+[p])
        except:
            print "Update of %s failed!"%p
        print "Done!"

def stepUp():
    for p in Environment():
        a = raw_input("updating %s, confirm? (y/n)"%p)
        if a =='y':
            try:
                install(['-U']+[p])
            except:
                print "Update of %s failed!"%p
        else:
            print "Skipping %s"%p
        print "Done!"
            
print "You have %s packages currently managed through Easy_install"%len(plist)
print plist
ans = raw_input('Do you want to update them... (N)ot at all, (O)ne-by-one, (A)utomatically (without prompting)')
if ans == 'N':
    sys.exit()
elif ans == 'O':
    stepUp()
elif ans == 'A':
    autoUp()
else:
    pass
{% endhighlight %} 