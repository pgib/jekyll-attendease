module Jekyll
  module AttendeasePlugin
    class VenuesIndexPage < Page
      def initialize(site, base, dir, venues)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'layouts'), 'venues.html')

        self.data['title'] = site.config['venues_index_title'] || 'Venues'

        self.data['venues'] = venues

        self.content = File.read(File.join(base, '_attendease', 'templates', 'venues', 'index.html'))
      end
    end
  end
end

