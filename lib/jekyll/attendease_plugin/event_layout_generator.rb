module Jekyll
  module AttendeasePlugin
    class EventLayoutGenerator < Generator
      safe true

      priority :high

      def generate(site)
        Jekyll.logger.debug "[Attendease] Generating theme layouts..."

        attendease_precompiled_theme_layouts_path = File.join(site.source, 'attendease_layouts') # These are compiled to the html site.
        attendease_precompiled_theme_email_layouts_path = File.join(site.source, 'attendease_layouts', 'emails') # These are compiled for email.
        attendease_theme_layouts_path = File.join(site.source, '_attendease_layouts') # These are used for page generation (no output html file needed)

        FileUtils.mkdir_p(attendease_precompiled_theme_layouts_path)
        FileUtils.mkdir_p(attendease_precompiled_theme_email_layouts_path)
        FileUtils.mkdir_p(attendease_theme_layouts_path)


        # Precompiled layouts for attendease app and jekyll generated pages.
        base_layout = site.config['attendease']['base_layout']
        layouts_to_precompile = %w{ layout register surveys } # These are compiled to the html site.
        layouts_to_precompile.each do |layout|
          # create a layout file if it already doesn't exist.
          # the layout file will be used by attendease to wrap /register, /schedule, /presenters, '/surveys'
          # in the look these compiled file define.
          # ensure {{ content }} is in the file so we can render content in there!
          unless File.exists?(File.join(attendease_precompiled_theme_layouts_path, "#{layout}.html"))
            site.pages << EventLayoutPage.new(site, site.source, 'attendease_layouts', "#{layout}.html", base_layout, layout.capitalize)
          end
        end


        # Precompiled layouts for attendease email
        base_email_layout = site.config['attendease']['base_email_layout']
        layouts_to_precompile = %w{ layout } # These are pre-compiled for email.
        layouts_to_precompile.each do |layout|
          # create a layout file if it already doesn't exist.
          unless File.exists?(File.join(attendease_precompiled_theme_email_layouts_path, "#{layout}.html"))
            site.pages << EventLayoutPage.new(site, site.source, 'attendease_layouts', 'emails', "#{layout}.html", base_email_layout, layout.capitalize)
          end
        end


        # Layouts to use for page generation. (These layouts do not need to be part of the html output)
        layouts_for_page_generation = %w{ layout register surveys schedule presenters venues sponsors }
        layouts_for_page_generation.each do |layout|
          base_layout_path = File.join(site.source, '_layouts', "#{base_layout}.html")

          unless File.exists?(base_layout_path)
            Jekyll.logger.debug "Could not find _layouts/#{base_layout}.html in your site source. Using the built-in template from jekyll-attendease."

            source_template = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'templates', 'layout.html'))
            html = Liquid::Template.parse(File.read(source_template)).render('page' => { 'base_layout' => base_layout })

            File.open(base_layout_path, 'w') { |f| f.write(html) }
          end

          unless File.exists?(File.join(attendease_theme_layouts_path, "#{layout}.html"))
            FileUtils.cp base_layout_path, File.join(site.source, '_attendease_layouts', "#{layout}.html")
          end
        end

      end
    end
  end
end
