module Jekyll
  module AttendeasePlugin
    class EventThemesGenerator < ::Jekyll::Generator
      safe true

      priority :high

      def generate(site)
        puts "[Attendease] Generating theme layouts..."

        attendease_precompiled_theme_layouts_path = "#{site.source}/attendease_layouts"

        FileUtils.mkdir_p(attendease_precompiled_theme_layouts_path)

        base_layout = (site.config['attendease'] && site.config['attendease']['base_layout']) ? site.config['attendease']['base_layout'] : 'layout'

        layouts_to_precompile = ['layout', 'register', 'schedule', 'presenters', 'venues', 'sponsors']

        # Precompiled layout for website sections.
        layouts_to_precompile.each do |layout|
          if File.exists?("#{site.source}/_layouts/#{base_layout}.html")

            # create a layout file if it already doesn't exist.
            # the layout file will be used by attendease to wrap /register, /schedule, /presnters in the
            # look the compiled file defines.
            # ensure {{ content }} is in the file so we can render content in there!
            if !File.exists?("#{attendease_precompiled_theme_layouts_path}/#{layout}.html")
              theme_layout_content = File.read("#{site.source}/_layouts/#{base_layout}.html")
              File.open("#{site.source}/attendease_layouts/#{layout}.html", 'w+') { |file| file.write(theme_layout_content) }
              site.pages << AttendeaseLayoutPage.new(site, site.source, 'attendease_layouts', "#{layout}.html", base_layout)
            end
          end
        end
      end
    end
  end
end
