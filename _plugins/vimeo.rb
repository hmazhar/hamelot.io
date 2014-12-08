# A plugin for embedding videos from Vimeo using a simple Liquid tag, ie: {% vimeo 12345678 %}.
# Based of the Youtube plugin from http://www.portwaypoint.co.uk/jekyll-youtube-liquid-template-tag-gist/
require 'vimeo'

module Jekyll
  class VimeoBlock < Liquid::Tag
    def initialize(name, id, tokens)
      super
      @id = id
    end

    def render(context)
      info = Vimeo::Simple::Video.info(@id).first
      <<-EOF
      <div class="col-sm-6 col-md-4">
      <div class="thumbnail">
      <a href="#{info["url"]}" ><img style="width: 100%" alt="#{info["title"]}" src="#{info["thumbnail_large"]}"/></a>
      <div class="caption">
      <h4> <a href="#{info["url"]}"> #{info["title"]} </a></h4>
      </div>
      </div>
      </div>
      EOF

    end
  end
end

Liquid::Template.register_tag('vimeoblock', Jekyll::VimeoBlock)