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



<p>These are some research projects that I have worked on or am currently working on</p>
<div class="well">
<div style="display:none;" class="html5gallery" data-skin="darkness" data-width="875" data-height="600" data-autoplayvideo="false" data-showsocialmedia="false">
       <a href="http://player.vimeo.com/video/37535122"><img <?php getID(37535122) ?> ></a>
       <a href="http://player.vimeo.com/video/37532106"><img <?php getID(37532106) ?> ></a>
       <a href="http://player.vimeo.com/video/48886085"><img <?php getID(48886085) ?> ></a>
       <a href="http://player.vimeo.com/video/33081330"><img <?php getID(33081330) ?> ></a>
       <a href="http://player.vimeo.com/video/31810675"><img <?php getID(31810675) ?> ></a>
       <a href="http://player.vimeo.com/video/31810009"><img <?php getID(31810009) ?> ></a>
       <a href="http://player.vimeo.com/video/31809875"><img <?php getID(31809875) ?> ></a>
       <a href="http://player.vimeo.com/video/53651625"><img <?php getID(53651625) ?> ></a>
       <a href="http://player.vimeo.com/video/53651626"><img <?php getID(53651626) ?> ></a>
       <a href="http://player.vimeo.com/video/53651629"><img <?php getID(53651629) ?> ></a>
       <a href="http://player.vimeo.com/video/53651631"><img <?php getID(53651631) ?> ></a>
       <a href="http://player.vimeo.com/video/53651632"><img <?php getID(53651632) ?> ></a>

    </div>
</div>