---
layout: default
title : Media
description:
---
<?php
function getID($imgid){
$hash = unserialize(file_get_contents("http://vimeo.com/api/v2/video/$imgid.php"));
echo 'src="' . $hash[0]['thumbnail_medium'] . '"' . 'alt="' . $hash[0]['title'] . '"';  
}
?>



<p>These are some videos of simulations I have worked on</p>
<div class="well">
<div style="display:none;" class="html5gallery" data-skin="darkness" data-width="875" data-height="600" data-autoplayvideo="false" data-showsocialmedia="false">
{{&vimeo_video}}

    </div>
</div>
