module Jekyll
  module AttendeasePlugin
    class SponsorsIndexPage < Page
      def initialize(site, base, dir, sponsor_levels)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'templates', 'sponsors'), 'index.html')

        self.data['title'] = site.config['sponsors_index_title'] || 'Sponsors'

        self.data['sponsor_levels'] = sponsor_levels
      end
    end
  end
end

