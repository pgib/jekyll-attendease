module Jekyll
  module AttendeasePlugin
    class RedirectPage < Page
      def initialize(site, base, dir, redirect_url)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)


        self.data = {}

        self.data['redirect_url'] = redirect_url

        self.content = File.read(File.join(File.dirname(__FILE__), '..', '..', '..', 'templates', 'redirect.html'))
      end
    end
  end
end

