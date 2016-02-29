---
layout: post
title: Jekyll Github Hook
date: '2016-02-26'
description: Setting up jekyll with a github webhook using hookshot
categories: other
tags: [node, jekyll, github]
---

There are a [few](https://github.com/developmentseed/jekyll-hook) [scripts](https://github.com/logsol/Github-Auto-Deploy) online that will launch a script when a [Github Webhook](https://help.github.com/articles/about-webhooks/) is activated. I found that [Hookshot](https://www.npmjs.com/package/hookshot) was the simplest and most customizable way to do what I wanted. It is a simple library that will handle 

## Setting up the Webhook

~~~bash
npm install -g hookshot
~~~

It can be used to execute scripts or commands when a specific branch in a repository is pushed to, in this example port 8080 is where the github hook is sent to.

~~~bash
hookshot -p 8080 -r refs/heads/master 'path_to_custom_script.sh'
~~~

Hookshot can also be configured to run using [forever](https://www.npmjs.com/package/forever) by using the js interface:

~~~js
//hookshot.js:
#!/usr/bin/env node
var hookshot = require('hookshot');
hookshot('refs/heads/master', 'path_to_custom_script.sh').listen(8080)
~~~


~~~bash
forever start hookshot.js
~~~

If you want this command to run on reboot (if your server restarts for some reason) add the following to your crontab

~~~bash
crontab -e
~~~

~~~bash
@reboot cd /path/to/script forever hookshot.js
~~~

If using [nginx](https://www.nginx.com/) you can set up your config to send the webhook to a specific port. This makes it easy to set up multiple hooks to different addresses/ports and have multiple instances of hookshor listening to different ports. 

~~~
server {
        listen  [::]:80;
        listen  80;
        server_name     hooks.website.org;

        location / {
                proxy_pass	 http://localhost:8080;
                proxy_set_header Host	   $host;
                proxy_set_header X-Real-IP $remote_addr;
        }
}
~~~

and then under github set the url to 

~~~
http://hooks.website.org
~~~


## Running Jekyll

Once the webhook has activated hookshot will run whatever script we provide. In this case we could do something like:

~~~bash
#!/bin/bash
cd /path/to/repo/
git pull
jekyll build -s /path/to/source -d /path/to/destination
~~~

