require 'httparty'
require 'json'

module Jekyll
  module Attendease

    class EventData < Generator
      def generate(site)
        if attendease_config = site.config['attendease']

          if attendease_config['api_host'] && !attendease_config['api_host'].match(/^http(.*).attendease.com/)
            raise "Is your Attendease api_host site properly in _config.yml? Needs to be something like https://myevent.attendease.com/"
          else
            # add a trailing slash if we are missing one.
            if attendease_config['api_host'][-1, 1] != '/'
              attendease_config['api_host'] += '/'
            end

            attendease_data_path = "#{site.config['source']}/_attendease_data"

            FileUtils.mkdir_p(attendease_data_path)

            update_data = true

            if File.exists?("#{attendease_data_path}/site.json")
              if (Time.now.to_i - File.mtime("#{attendease_data_path}/site.json").to_i) <= 30 # file is less than 30 seconds old
                update_data = false

                site_json = File.read("#{attendease_data_path}/site.json")

                event_data = JSON.parse(site_json)
              end
            end

            if update_data
              event_data = HTTParty.get("#{attendease_config['api_host']}api/site.json")

              if !event_data['error']
                puts "Saving attendease event data..."

                File.open("#{attendease_data_path}/site.json", 'w+') { |file| file.write(event_data.parsed_response.to_json) }
              else
                raise "Event data not found, is your Attendease api_host site properly in _config.yml?"
              end
            end

            # Adding to site config so we can access these variables globally wihtout using a Liquid Tag so we can use if/else
            site.config['attendease']['data'] = {}

            event_data.keys.each do |tag|
              site.config['attendease']['data'][tag] = event_data[tag]
            end
          end

        else
          raise "Please set the Attendease config in your _config.yml"
        end
      end
    end


    class EventThemes < Generator
      def generate(site)
        puts "Generating theme layout..."

        attendease_precompiled_theme_layouts_path = "#{site.config['source']}/attendease_layouts"

        FileUtils.mkdir_p(attendease_precompiled_theme_layouts_path)

        layouts_to_precompile = ['layout', 'register', 'schedule', 'presenters']

        # Precompiled layout for website sections.
        layouts_to_precompile.each do |layout|
          if File.exists?("#{site.config['source']}/_layouts/layout.html")

            # create a layout file if is already doesn't exist.
            # the layout file will be used by attendease to wrap /register, /schedule, /presnters in the
            # look the compiled file defines.
            # ensure {{ content }} is in the file so we can render content in there!
            if !File.exists?("#{site.config['source']}/attendease_layouts/#{layout}.html")
              theme_layout_content = <<-eos
---
layout: layout
---

{% raw %}
{{ content }}
{% endraw %}
              eos

              File.open("#{site.config['source']}/attendease_layouts/#{layout}.html", 'w+') { |file| file.write(theme_layout_content) }
            end
          end
        end

      end
    end

  end
end