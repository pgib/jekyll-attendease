module Jekyll
  module AttendeasePlugin
    class VenuePage < Page
      def initialize(site, base, dir, venue)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'venues.html')

        venue_page_title = site.config['venue_page_title'] ? site.config['venue_page_title'] : 'Venue: %s'
        self.data['title'] = sprintf(venue_page_title, venue['name'])

        self.data['venue'] = venue

        if File.exists?(File.join(base, '_includes', 'attendease', 'venues', 'venue.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'venues', 'venue.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'venues/venue.html')) # Use template
        end
      end
    end
  end
end

