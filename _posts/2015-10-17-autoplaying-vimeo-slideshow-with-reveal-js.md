---
layout: post
title: Reveal.js Vimeo slideshow
date: '2015-10-17'
description: An Autoplaying slideshow for vimeo videos using reveal.js
categories: other
tags: [javascript]
---

In the lab we've sometimes had to show videos at open-house like events for the department or when visitors come. I'd implemented a slideshow using reveal.js and froogaloop in the past but the code was lost to time. I figured that this time I would document it for future use. 

For completeness a working example is [here](https://github.com/hmazhar/vimeo_slideshow)

Beyond the Reveal.js and Froogaloop documentations [this](http://labs.funkhausdesign.com/examples/vimeo/froogaloop2-api-basics.html) page has a useful example. 

###Specifications:
* Start when user hits the right/left arrow or the play button is clicked on the first video
* Pause the current video if the next/previous slide is pressed before the current video ends
* Specify videos in a list that can easily be added/removed from


We will be using the [froogaloop 2](https://github.com/vimeo/player-api/tree/master/javascript) javascript library
{% highlight html %}
<script src="http://a.vimeocdn.com/js/froogaloop2.min.js"></script>   
{% endhighlight %}

Create an empty slide div that will be filled in dynamically

{% highlight html %}
<div class="reveal">
    <!-- Empty slide container that will be filled in using javascript -->
    <div class="slides" id="SLIDES">
    </div>
  </div>
{% endhighlight %}


Loop over all of the videos in the list and add the associated vimeo iframe for that video. Specify the size of the iframe/vimeo video here.

{% highlight js %}
var videos = [142659744,142659745, 140448032];
    var div = document.getElementById('SLIDES');

    for (i = 0; i < videos.length; i++) { 
      sec = document.createElement("section");
      ifrm = document.createElement("IFRAME");
      ifrm.setAttribute("src", "https://player.vimeo.com/video/"+videos[i]+"?byline=0&portrait=0&player_id=player"+i);
      ifrm.setAttribute("class","vimeo");
      ifrm.setAttribute("id","player"+i);
      ifrm.style.width = 1200+"px";
      ifrm.style.height = 700+"px";
      sec.appendChild(ifrm);
      div.appendChild(sec);
    {% endhighlight %}

    Initialize Reveal.js, this is where we can specify the size of the slide, and other parameters. See the [Reveal.js documentation](https://github.com/hakimel/reveal.js) for more info

{% highlight js %}
    Reveal.initialize({
      controls: true,
      center: true,
      loop: true,
      width: 1300,
      height: 700,
      transition: 'fade', // none/fade/slide/convex/concave/zoom
    });
{% endhighlight %}

Setup the froogaloop API so that the slide will go to the right when the video finishes playing

{% highlight js %}
    jQuery(document).ready(function() {
        // Enable the API on each Vimeo video
        jQuery('iframe.vimeo').each(function(){
          Froogaloop(this).addEvent('ready', ready);
        });
        function ready(playerID){
          Froogaloop(playerID).addEvent('finish', onFinish);
        }
        function onFinish(id) {
          Reveal.right();
        }
    {% endhighlight %}  

Once a slide is changed, get the vimeo iframe for the new slide, play the video on that slide

{% highlight js %}
    var vimeoPlayers = jQuery('iframe.vimeo')
    Reveal.addEventListener( 'slidechanged', function( event ) {
      var state = Reveal.getState();
      Froogaloop(vimeoPlayers[state.indexh]).api('play');
    } );
    {% endhighlight %}

Reveal.js allows for custom keyboard functions, if the slide is changed by the user before the current video finishes, pause the video and change the slide. 

{% highlight js %}
    Reveal.configure({
      keyboard: {
        37: function() {
          var state = Reveal.getState();
          Froogaloop(vimeoPlayers[state.indexh]).api('pause');
          Reveal.left();
        },
        39: function() {
          var state = Reveal.getState();
          Froogaloop(vimeoPlayers[state.indexh]).api('pause');
          Reveal.right();
        }
      }
    });
{% endhighlight %} 