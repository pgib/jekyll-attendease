module Jekyll
  module AttendeasePlugin
    class VenuePage < Page
      def initialize(site, base, dir, venue)
        @site = site
        @base = base
        @dir = dir
        @name = venue['slug']

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'venues.html')

        venue_page_title = site.config['venue_page_title'] ? site.config['venue_page_title'] : 'Venue: %s'
        self.data['title'] = sprintf(venue_page_title, venue['name'])

        self.data['venue'] = venue

        self.content = File.read(File.join(base, '_attendease', 'templates', 'venues', 'venue.html'))
      end
    end
  end
end

