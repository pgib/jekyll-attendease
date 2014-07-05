module Jekyll
  module AttendeasePlugin
    class LayoutPage < Page
      def initialize(site, base, dir, name, base_layout)
        @site = site
        @base = base
        @dir = dir
        @name = name

        self.process(name)

        self.read_yaml(File.expand_path(File.dirname(__FILE__) + "/../templates"), 'layout.html') # a template for the layout.

        self.data['layout'] = base_layout
      end
    end
  end
end

