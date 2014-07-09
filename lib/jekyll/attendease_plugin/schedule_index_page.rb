module Jekyll
  module AttendeasePlugin
    class ScheduleIndexPage < Page
      def initialize(site, base, dir, dates)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'schedule.html')

        self.data['title'] = site.config['schedule_index_title_prefix'] || 'Schedule'

        self.data['dates'] = dates

        self.content = File.read(File.join(base, '_attendease', 'templates', 'schedule', 'index.html'))
      end
    end
  end
end

