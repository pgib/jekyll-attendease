module Jekyll
  module AttendeasePlugin
    class HomePage < Page
      def initialize(site, base, dir)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        base_layout = site.config['attendease']['base_layout'] || 'layout'

        self.read_yaml(File.join(site.source, '_layouts'), "#{base_layout}.html")

        self.data['title'] = site.config['homepage_title'] || 'Welcome'

        # Check if Attendease API has a template for this page
        if template = Helpers.get_template(site, 'index')
          # use the template file from the attendease api
          self.content = template
        else
          # use the included template in the gem
          self.content = File.read(File.join(base, '_attendease', 'templates', 'index.html'))
        end
      end
    end
  end
end

