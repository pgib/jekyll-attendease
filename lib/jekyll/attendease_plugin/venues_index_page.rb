module Jekyll
  module AttendeasePlugin
    class VenuesIndexPage < Page
      def initialize(site, base, dir, venues)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'venues.html')

        self.data['title'] = site.config['venues_index_title'] || 'Venues'

        self.data['venues'] = venues

        if File.exists?(File.join(base, '_includes', 'attendease', 'venues', 'index.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'venues', 'index.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'venues/index.html')) # Use template
        end
      end
    end
  end
end

