module Jekyll
  module AttendeasePlugin
    class ScheduleSessionsPage < Page
      def initialize(site, base, dir, sessions, dates)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'templates', 'schedule'), 'sessions.html')

        self.data['title'] = site.config['schedule_sessions_title'] || 'Schedule: Sessions'

        sessionsData = []

        self.data['sessions'] = sessions
        self.data['dates'] = dates
      end
    end
  end
end

