require 'vimeo'
    class Ruhoh
    module Templaters
    module Helpers
    def greeting
    "Hello there! How are you?"
    end
    def vimeo_video
    files=["37535122","37532106","48886085","33081330","31810675","31810009","31809875","53651625","53651626","53651629","53651631","53651632"]
	var=""
	files.each{ |x|
		video_info=Vimeo::Simple::Video.info(x)
		var=var+"<a href=\"http://player.vimeo.com/video/#{x}\"> <img src=\"#{video_info[0]["thumbnail_medium"]}\" alt=\"#{video_info[0]["title"]}\" ></a>\n"
    }
    var=var+""
	end
    end
    end
    end
