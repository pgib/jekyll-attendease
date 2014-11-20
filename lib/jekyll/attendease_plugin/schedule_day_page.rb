module Jekyll
  module AttendeasePlugin
    class ScheduleDayPage < Page
      def initialize(site, base, dir, day, sessions, dates)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'layouts'), 'schedule.html')

        session_day_title_prefix = site.config['schedule_day_title_prefix'] || 'Schedule: '
        self.data['title'] = "#{session_day_title_prefix}#{day['date_formatted']}"

        self.data['day'] = day
        self.data['dates'] = dates

        instances = []

        sessions.each do |s|
          s['instances'].each do |instance|
            if instance['date'] == day['date']
              instance['session'] = s
              instances << instance
            end
          end
        end

        self.data['instances'] = instances.sort{|x,y| [x['time'], x['session']['name']] <=> [y['time'], y['session']['name']]}

        # Check if Attendease API has a template for this page
        if template = Helpers.get_template(site, 'schedule/day')
          # use the template file from the attendease api
          self.content = template
        else
          # use the included template in the gem
          self.content = File.read(File.join(base, '_attendease', 'templates', 'schedule', 'day.html'))
        end
      end
    end
  end
end

