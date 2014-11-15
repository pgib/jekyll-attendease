module Jekyll
  module AttendeasePlugin
    class ScheduleSessionsPage < Page
      def initialize(site, base, dir, sessions, dates)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'layouts'), 'schedule.html')

        self.data['title'] = site.config['schedule_sessions_title'] || 'Schedule: Sessions'

        sessionsData = []

        self.data['sessions'] = sessions
        self.data['dates'] = dates

        # Check if Attendease API has a template for this page
        if template = Helpers.get_template(site, 'schedule/sessions')
          # use the template file from the attendease api
          self.content = template
        else
          # use the included template in the gem
          self.content = File.read(File.join(base, '_attendease', 'templates', 'schedule', 'sessions.html'))
        end
      end
    end
  end
end

