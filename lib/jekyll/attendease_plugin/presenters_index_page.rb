module Jekyll
  module AttendeasePlugin
    class PresentersIndexPage < Page
      def initialize(site, base, dir, presenters)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'templates', 'presenters'), 'index.html')

        self.data['title'] = site.config['presenters_index_title'] || 'Presenters'

        self.data['presenters'] = presenters
      end
    end
  end
end

