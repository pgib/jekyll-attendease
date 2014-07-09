module Jekyll
  module AttendeasePlugin
    class EventLayoutGenerator < ::Jekyll::Generator
      safe true

      priority :high

      def generate(site)
        Jekyll.logger.debug "[Attendease] Generating theme layouts..."

        attendease_precompiled_theme_layouts_path = File.join(site.source, 'attendease_layouts')

        FileUtils.mkdir_p(attendease_precompiled_theme_layouts_path)

        base_layout = site.config['attendease']['base_layout']

        layouts_to_precompile = %w{ layout register schedule presenters venues sponsors }

        # Precompiled layout for website sections.
        layouts_to_precompile.each do |layout|
          if File.exists?(File.join(site.source, 'attendease_layouts', "#{base_layout}.html"))
            # create a layout file if it already doesn't exist.
            # the layout file will be used by attendease to wrap /register, /schedule, /presenters in the
            # look the compiled file defines.
            # ensure {{ content }} is in the file so we can render content in there!
            unless File.exists?(File.join(attendease_precompiled_theme_layouts_path, "#{layout}.html"))
              FileUtils.cp File.join(site.source, 'attendease_layouts', "#{base_layout}.html"), File.join(site.source, 'attendease_layouts', "#{layout}.html")
              #site.pages << LayoutPage.new(site, site.source, 'attendease_layouts', "#{layout}.html", base_layout)
            end
          else
            Jekyll.logger.debug "Could not find attendease_layouts/#{base_layout}.html in your site source. Using the built-in template from jekyll-attendease."
            #FileUtils.cp File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'templates', 'layout.html')), File.join(site.source, 'attendease_layouts', "#{base_layout}.html")
            source_template = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'templates', 'layout.html'))
            html = Liquid::Template.parse(File.read(source_template)).render('page' => { 'base_layout' => base_layout })

            File.open(File.join(site.source, 'attendease_layouts', "#{base_layout}.html"), 'w') { |f| f.write(html) }
            #site.pages << LayoutPage.new(site, site.source, 'attendease_layouts', "#{layout}.html", base_layout)
          end
        end
      end
    end
  end
end
