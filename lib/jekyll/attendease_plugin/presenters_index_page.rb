module Jekyll
  module AttendeasePlugin
    class PresentersIndexPage < Page
      def initialize(site, base, dir, presenters)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'layouts'), 'presenters.html')

        self.data['title'] = site.config['presenters_index_title'] || 'Presenters'

        self.data['presenters'] = presenters

        # Check if Attendease API has a template for this page
        if template = Helpers.get_template(site, 'presenters/index')
          # use the template file from the attendease api
          self.content = template
        else
          # use the included template in the gem
          self.content = File.read(File.join(base, '_attendease', 'templates', 'presenters', 'index.html'))
        end
      end
    end
  end
end

