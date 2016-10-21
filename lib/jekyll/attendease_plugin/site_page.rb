module Jekyll
  module AttendeasePlugin
    class SitePage < Page
      def initialize(site, base, page)
        @site = site
        @base = base
        @dir = page['slug']
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'templates', 'pages'), 'default.html')

        self.data['title'] = page['title']

        self.data['site_page'] = page
      end
    end
  end
end
