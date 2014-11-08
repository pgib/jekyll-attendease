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

        # Check if Attendease API has a template for this page
        if template = Helpers.get_template(site, 'venues/index')
          # use the template file from the attendease api
          self.content = template
        else
          # use the included template in the gem
          self.content = File.read(File.join(base, '_attendease', 'templates', 'venues', 'index.html'))
        end
      end
    end
  end
end

