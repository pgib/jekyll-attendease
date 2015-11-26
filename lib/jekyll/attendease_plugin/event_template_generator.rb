# Create `templates` under `_attendease`.
# These templates will be used to generate all the attendease pages
# - /index.html (Homepage - if it already doesn't exist)
# - /schedule/index.html (Show a schedule index page if `show_schedule_index` is true. Otherwise it will show the first day.)
# - /schedule/day.html (Session timeslots for that day)
# - /schedule/sessions.html (All sessions)
# - /schedule/session.html (An individual session)
# - /presenters/index.html (All presenters)
# - /presenters/presenter.html (An individual presenter)
# - /venues/index.html (All venues)
# - /venues/venue.html (An individual venue)
# - /sponsors/index.html (All sponsors)

# These widgets will be used for specific tags
# - /schedule/widget.html (A embeddable schedule widget)

module Jekyll
  module AttendeasePlugin
    class EventTemplateGenerator < Generator
      safe true

      priority :high

      def generate(site)
        Jekyll.logger.info "[Attendease] Generating theme templates..."

        # Generate the template files if they don't yet exist.
        %w{ schedule presenters venues sponsors}.each do |p|
          path = File.join(site.source, '_attendease', 'templates', p)
          FileUtils.mkdir_p(path)
          raise "Could not create #{path}." unless File.exists?(path)
        end

        template_path = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'templates', 'attendease'))

        # Precompiled layouts for attendease app and jekyll generated pages.
        base_layout = site.config['attendease']['base_layout'] || 'layout'

          front_matter = <<EOF
---
layout: #{base_layout}
---

EOF

        %w{
          index
          schedule/index
          schedule/day
          schedule/sessions
          schedule/session
          presenters/index
          presenters/presenter
          venues/index
          venues/venue
          sponsors/index
        }.each do |page|
          destination_file = File.join(site.source, '_attendease', 'templates', "#{page}.html")

          unless File.exists?(destination_file)
            template_data = front_matter + File.read(File.join(template_path, "#{page}.html"))
            File.open(destination_file, 'w+') { |f| f.write(template_data) }
          end
        end

        # Schedule widget
        page = 'schedule/widget'

        destination_file = File.join(site.source, '_attendease', 'templates', "#{page}.html")

        unless File.exists?(destination_file)
          template_data = File.read(File.join(template_path, "#{page}.html"))
          File.open(destination_file, 'w+') { |f| f.write(template_data) }
        end

      end

    end
  end
end
