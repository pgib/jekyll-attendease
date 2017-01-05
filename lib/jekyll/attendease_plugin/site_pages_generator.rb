module Jekyll
  module AttendeasePlugin
    class SitePagesGenerator < Generator
      safe true

      def generate(site)
        site.config['attendease']['pages'].each do |page|
          if !page['permanent']
            site.pages << SitePage.new(site, site.source, page)

            zones = {}

            if page['block_instances'].length
              # create zone buckets
              page['block_instances'].each do |i|
                zones[i['zone']] = [] if zones[i['zone']].nil?
                zones[i['zone']] << i
              end

              # sort each bucket by widget weight
              zones.each do |k, zone|
                zone.sort! { |x, y| x['weight'] <=> y['weight'] }
              end

              page_source_path = File.join(site.source, page['slug'])
              FileUtils.mkdir_p(page_source_path) unless File.exists?(page_source_path)

              File.open(File.join(page_source_path, 'index.json'), 'w') do |f|
                f.write zones.to_json
                f.close
              end

              site.static_files << StaticFile.new(site, site.source, File.join('', page['slug']), 'index.json')
            end
          end
        end
      end
    end
  end
end
