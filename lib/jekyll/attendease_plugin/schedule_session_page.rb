module Jekyll
  module AttendeasePlugin
    class ScheduleSessionPage < Page
      def initialize(site, base, dir, session)
        @site = site
        @base = base
        @dir = dir
        @name = session['slug']

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'layouts'), 'schedule.html')

        schedule_session_page_title = site.config['schedule_session_page_title'] || 'Schedule: %s'
        self.data['title'] = sprintf(schedule_session_page_title, session['name'])

        self.data['session'] = session

        # Check if Attendease API has a template for this page
        if template = Helpers.get_template(site, 'schedule/session')
          # use the template file from the attendease api
          self.content = template
        else
          # use the included template in the gem
          self.content = File.read(File.join(base, '_attendease', 'templates', 'schedule', 'session.html'))
        end
      end
    end
  end
end

