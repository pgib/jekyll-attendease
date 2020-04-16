# Create attendease layouts in `_layouts`.
# These layouts will be used in page generators
# - /attendease_home.html (Home page)
# - /attendease_presenters.html (Presenter pages)
# - /attendease_schedule.html (Schedule pages)
# - /attendease_sponsors.html (Sponsor pages)
# - /attendease_venues.html (Venue pages)

module Jekyll
  module AttendeasePlugin
    class EventLayoutGenerator < Generator
      safe true

      priority :high

      def generate(site)
        Jekyll.logger.debug "[Attendease] Generating theme layouts..."

        layouts_path = File.join(site.source, '_layouts')

        cms_layouts = []
        begin
          Dir.glob(File.join(layouts_path, '*.html')).each do |l|
            html = File.read(l)
            if html =~ %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m
              data = YAML.load(Regexp.last_match(1))
              if data['cms_layout']
                cms_layouts << File.basename(l).split('.').first
              end
            end
          end
        rescue
        end

        cms_layouts.each do |layout|
          site.pages << EventLayoutPage.new(site, site.source, 'attendease_layouts', "cms-#{layout}.html", layout, layout.capitalize)
        end

        return unless site.config.live_mode?

        attendease_precompiled_theme_layouts_path = File.join(site.source, 'attendease_layouts') # These are compiled to the html site.
        attendease_precompiled_theme_email_layouts_path = File.join(site.source, 'attendease_layouts', 'emails') # These are compiled for email.

        FileUtils.mkdir_p(attendease_precompiled_theme_layouts_path)

        # Precompiled layouts for attendease app and jekyll generated pages.
        base_layout = site.config['attendease']['base_layout'] || 'layout'

        base_layout_file = File.join(layouts_path, "#{base_layout}.html")
        unless File.exists?(base_layout_file)
          # Generate an extremely simple base layout if it does not exist.
          File.open(base_layout_file, 'w+') { |f| f.write("{{ content }}") }
        end

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
        base_email_layout = site.config['attendease']['base_email_layout'] || 'email'
        base_email_layout_file = File.join(layouts_path, "#{base_email_layout}.html")
        unless File.exists?(base_email_layout_file)
          # Generate an extremely simple base email layout if it does not exist.
          File.open(base_email_layout_file, 'w+') { |f| f.write("{{ content }}") }
        end

        layouts_to_precompile = %w{ layout } # These are pre-compiled for email.
        layouts_to_precompile.each do |layout|
          # create a layout file if it already doesn't exist.
          unless File.exists?(File.join(attendease_precompiled_theme_email_layouts_path, "#{layout}.html"))
            site.pages << EventLayoutPage.new(site, site.source, 'attendease_layouts/emails', "#{layout}.html", base_email_layout, layout.capitalize)
          end
        end
      end
    end
  end
end
