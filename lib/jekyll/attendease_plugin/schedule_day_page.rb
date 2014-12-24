module Jekyll
  module AttendeasePlugin
    class ScheduleDayPage < Page
      def initialize(site, base, dir, day, sessions, dates)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'templates', 'schedule'), 'day.html')

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
      end
    end
  end
end

