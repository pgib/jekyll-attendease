module Jekyll
  module AttendeasePlugin
    class SponsorsIndexPage < Page
      def initialize(site, base, dir, sponsor_levels)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'sponsors.html')

        self.data['title'] = site.config['sponsors_index_title'] || 'Sponsors'

        self.data['sponsor_levels'] = sponsor_levels

        if File.exists?(File.join(base, '_includes', 'attendease', 'sponsors', 'index.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'sponsors', 'index.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'sponsors/index.html')) # Use template
        end
      end
    end
  end
end

