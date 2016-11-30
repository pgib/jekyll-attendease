module Jekyll
  module AttendeasePlugin
    class SitePage < Page
      def initialize(site, base, page)
        @site = site
        @base = base
        @dir = page['slug']
        @name = 'index.html'

        self.process(@name)

        #require 'pry'
        #binding.pry
        #self.read_yaml(File.join(base, '_attendease', 'templates', 'pages'), 'default.html')
        self.read_yaml(File.join(base, '_layouts'), "#{page['layout']}.html")

        self.data['title'] = page['title']
        self.data['layout'] = page['layout']

        zones = {}

        # create zone buckets
        page['widget_instances'].each do |i|
          zones[i['zone']] = [] if zones[i['zone']].nil?
          zones[i['zone']] << i
        end

        # sort each bucket by widget weight
        zones.each do |k, zone|
          zone.sort! { |x, y| y['weight'] <=> x['weight'] }
          self.data[k] = ''
          zone.each do |i|
            self.data[k] << i['rendered_html']
          end
        end

        self.data['site_page'] = page
      end
    end
  end
end
