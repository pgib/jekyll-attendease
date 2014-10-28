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

        if site.config['attendease'] && templates = site.config['attendease']['templates']
          if t = templates.detect{|t| t['page'] == 'index'}
            template = t['data']
          end
        end

        if template.nil?
          # use the included template in the gem
          self.content = File.read(File.join(base, '_attendease', 'templates', 'index.html'))
        else
          # use the template file from the attendease api
          self.content = template
        end
      end
    end
  end
end

