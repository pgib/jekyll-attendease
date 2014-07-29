module Jekyll
  module AttendeasePlugin
    class EventLayoutPage < Page
      def initialize(site, base, dir, name, base_layout, title_prefix)
        @site = site
        @base = base
        @dir = dir
        @name = name

        self.process(name)

        self.read_yaml(File.join(base, '_layouts'), "#{base_layout}.html")

        self.data = {}

        self.data['layout'] = base_layout
        self.data['base_layout'] = base_layout

        title_prefix = 'Hello' if title_prefix == 'Layout' # Use "Hello" for the title of the main layout page.

        self.data['title'] = title_prefix

        self.content = "{% raw %}{{ content }}{% endraw %}"
      end
    end
  end
end