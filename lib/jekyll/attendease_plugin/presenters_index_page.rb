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

        self.content = File.read(File.join(base, '_attendease', 'templates', 'presenters', 'index.html'))
      end
    end
  end
end

