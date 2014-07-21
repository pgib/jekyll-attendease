module Jekyll
  module AttendeasePlugin
    class EventLayoutPage < Page
      def initialize(site, base, dir, name, base_layout, title_prefix)
        @site = site
        @base = base
        @dir = dir
        @name = name

        self.process(name)

        self.read_yaml(File.join(File.dirname(__FILE__), '..', '..', '..', 'templates'), 'layout.html') # a template for the precompiled layout.

        self.data = {}
        self.data['layout'] = base_layout
        self.data['title'] = title_prefix
      end
    end
  end
end