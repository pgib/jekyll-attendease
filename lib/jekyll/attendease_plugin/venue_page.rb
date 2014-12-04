module Jekyll
  module AttendeasePlugin
    class VenuePage < Page
      def initialize(site, base, dir, venue)
        @site = site
        @base = base
        @dir = dir
        @name = venue['slug']

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'layouts'), 'venues.html')

        venue_page_title = site.config['venue_page_title'] ? site.config['venue_page_title'] : 'Venue: %s'
        self.data['title'] = sprintf(venue_page_title, venue['name'])

        self.data['venue'] = venue

        # Check if Attendease API has a template for this page
        if template = Helpers.get_template(site, 'venues/venue')
          # use the template file from the attendease api
          self.content = template
        else
          # use the included template in the gem
          self.content = File.read(File.join(base, '_attendease', 'templates', 'venues', 'venue.html'))
        end
      end
    end
  end
end

