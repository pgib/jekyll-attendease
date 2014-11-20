module Jekyll
  module AttendeasePlugin
    class ScheduleGenerator < Generator
      safe true

      attr_reader :schedule_data

      def generate(site)
        if site.config['attendease'] && site.config['attendease']['api_host'] && site.config['attendease']['generate_schedule_pages']

          @schedule_data = ScheduleDataParser.new(site)

          #
          # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          # /schedule pages.
          dir = site.config['attendease']['schedule_path_name']

          unless dir.nil?
            if (site.config['attendease'] && site.config['attendease']['show_day_index'])
              site.pages << ScheduleIndexPage.new(site, site.source, File.join(dir), @schedule_data.event['dates'])
            else
              site.pages << ScheduleDayPage.new(site, site.source, File.join(dir), @schedule_data.event['dates'].first, @schedule_data.sessions, @schedule_data.event['dates'])
            end

            site.pages << ScheduleSessionsPage.new(site, site.source, File.join(dir, 'sessions'), @schedule_data.sessions, @schedule_data.event['dates'])

            @schedule_data.event['dates'].each do |day|
              site.pages << ScheduleDayPage.new(site, site.source, File.join(dir, day['date']), day, @schedule_data.sessions, @schedule_data.event['dates'])
            end

            @schedule_data.sessions.each do |session|
              site.pages << ScheduleSessionPage.new(site, site.source, File.join(dir, 'sessions'), session)
            end
          end

          # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          # /presenters pages.
          dir = site.config['attendease']['presenters_path_name']

          unless dir.nil?
            @schedule_data.presenters.each do |presenter|
              site.pages << PresenterPage.new(site, site.source, dir, presenter, @schedule_data.sessions)
            end

            site.pages << PresentersIndexPage.new(site, site.source, File.join(dir), @schedule_data.presenters)
          end

          # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          # /venue pages.
          dir = site.config['attendease']['venues_path_name']

          unless dir.nil?
            @schedule_data.venues.each do |venue|
              site.pages << VenuePage.new(site, site.source, dir, venue)
            end

            site.pages << VenuesIndexPage.new(site, site.source, File.join(dir), @schedule_data.venues)
          end
        end
      end
    end
  end
end

