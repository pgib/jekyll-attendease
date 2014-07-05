module Jekyll
  module AttendeasePlugin
    class ScheduleSessionPage < Page
      def initialize(site, base, dir, session)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'schedule.html')

        schedule_session_page_title = site.config['schedule_session_page_title'] || 'Schedule: %s'
        self.data['title'] = sprintf(schedule_session_page_title, session['name'])

        self.data['session'] = session

        if File.exists?(File.join(base, '_includes', 'attendease', 'schedule', 'session.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'schedule', 'session.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'schedule/session.html')) # Use template
        end
      end
    end
  end
end

