module Jekyll
  module AttendeasePlugin
    class SitePagesGenerator < Generator
      safe true

      # site.config:
      #    Is where you can find the configs generated for your site
      #    To check the structure sample go in your vagrant to
      #    /home/vagrant/attendease/var/organizations/attendease/portal_site/_config.yml
      def generate(site)
        site.data['pages'].each do |page|
          if !page['external']
            require 'cgi'

            page['name'] = CGI.escapeHTML(page['name']) if page['name']
            site.pages << SitePage.new(site, site.source, page)

            zones = {}
            keys = %w[content preferences]

            if page['block_instances'].length
              # create zone buckets
              page['block_instances'].each do |i|
                # go through all content
                if site.config.event?
                  keys.each do |key|
                    i[key].each do |k, v|
                      if v.is_a?(String) && v.match(/\{\{/)
                        # maintain the {{ t.foo }} variables
                        v.gsub!(/(\{\{\s*t\.[a-z_.]+\s*\}\})/, '{% raw %}\1{% endraw %}')
                        i[key][k] = Liquid::Template.parse(v).render('event' => site.data['event'], 'mappable' => site.data['mappable'])
                      end
                    end
                  end

                  unless site.data['mappable'].nil? || site.data['mappable'].empty?
                    if i['content'].has_key?('cards') && i['content']['cards'].any?
                      i['content']['cards'].each do |card|
                        card.each_pair do |k, v|
                          if v.is_a?(String) && v.match(/\{\{/)
                            card[k] = Liquid::Template.parse(v).render('mappable' => site.data['mappable'])
                          end
                        end
                      end
                    end
                  end
                end

                zones[i['zone']] = [] if zones[i['zone']].nil?
                zones[i['zone']] << i
              end

              # sort each bucket by widget weight
              zones.each do |k, zone|
                zone.sort! { |x, y| x['weight'] <=> y['weight'] }
              end

              page_source_path = File.join(site.source, page['slug'])
              FileUtils.mkdir_p(page_source_path) unless File.exists?(page_source_path)

              json_filename = site.config.attendease['private_site'] ? 'index-private.json' : 'index.json'

              File.open(File.join(page_source_path, json_filename), 'w') do |f|
                f.write zones.to_json
                f.close
              end

              site.static_files << StaticFile.new(site, site.source, File.join('', page['slug']), json_filename)
            end
          end
        end
      end
    end
  end
end

