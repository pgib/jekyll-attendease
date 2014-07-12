module Jekyll
  module AttendeasePlugin
    class PreZeroPointSixLinkRedirectGenerator < ::Jekyll::Generator
      safe true

      priority :low

      def generate(site)
        if site.config['attendease']['generate_schedule_pages'] && site.config['attendease']['redirect_ugly_urls']
          schedule_generator = site.generators.select { |g| g.class == Jekyll::AttendeasePlugin::ScheduleGenerator }.first

          # presenters
          dir = site.config['attendease']['presenters_path_name']
          schedule_generator.presenters.each do |o|
            site.pages << RedirectPage.new(site, site.source, File.join(dir, o['id']), File.join('/', dir, o['slug']))
          end

          # venues
          dir = site.config['attendease']['venues_path_name']
          schedule_generator.venues.each do |o|
            site.pages << RedirectPage.new(site, site.source, File.join(dir, o['id']), File.join('/', dir, o['slug']))
          end

          # sessions
          dir = site.config['attendease']['schedule_path_name']
          schedule_generator.sessions.each do |o|
            site.pages << RedirectPage.new(site, site.source, File.join(dir, o['code']), File.join('/', dir, o['slug']))
          end
        end
      end # end generate

    end # end class
  end
end

