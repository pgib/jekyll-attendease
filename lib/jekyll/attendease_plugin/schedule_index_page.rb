module Jekyll
  module AttendeasePlugin
    class ScheduleIndexPage < Page
      def initialize(site, base, dir, dates)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'layouts'), 'schedule.html')

        self.data['title'] = site.config['schedule_index_title_prefix'] || 'Schedule'

        self.data['dates'] = dates

        # Check if Attendease API has a template for this page
        if template = Helpers.get_template(site, 'schedule/index')
          # use the template file from the attendease api
          self.content = template
        else
          # use the included template in the gem
          self.content = File.read(File.join(base, '_attendease', 'templates', 'schedule', 'index.html'))
        end
      end
    end
  end
end

