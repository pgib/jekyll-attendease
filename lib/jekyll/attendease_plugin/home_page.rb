module Jekyll
  module AttendeasePlugin
    class HomePage < Page
      def initialize(site, base, dir)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'templates'), 'index.html')

        self.data['title'] = site.config['homepage_title'] || 'Welcome'
      end
    end
  end
end

