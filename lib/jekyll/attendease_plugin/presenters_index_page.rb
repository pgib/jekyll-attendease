module Jekyll
  module AttendeasePlugin
    class PresentersIndexPage < Page
      def initialize(site, base, dir, presenters)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'presenters.html')

        self.data['title'] = site.config['presenters_index_title'] || 'Presenters'

        self.data['presenters'] = presenters

        if File.exists?(File.join(base, '_includes', 'attendease', 'presenters', 'index.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'presenters', 'index.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'presenters/index.html')) # Use template
        end
      end
    end
  end
end

