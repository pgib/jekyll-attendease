module Jekyll
  module AttendeasePlugin
    class SponsorsIndexPage < Page
      def initialize(site, base, dir, sponsor_levels)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'layouts'), 'sponsors.html')

        self.data['title'] = site.config['sponsors_index_title'] || 'Sponsors'

        self.data['sponsor_levels'] = sponsor_levels

        # Check if Attendease API has a template for this page
        if template = Helpers.get_template(site, 'sponsors/index')
          # use the template file from the attendease api
          self.content = template
        else
          # use the included template in the gem
          self.content = File.read(File.join(base, '_attendease', 'templates', 'sponsors', 'index.html'))
        end
      end
    end
  end
end

