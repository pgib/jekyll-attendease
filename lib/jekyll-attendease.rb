require 'httparty'
require 'json'

module Jekyll
  module Attendease

    class EventData < Generator
      def generate(site)
        if attendease_config = site.config['attendease']

          if attendease_config['api_host'] && !attendease_config['api_host'].match(/^http/)
            raise "Is your Attendease api_host site properly in _config.yml? Needs to be something like https://myevent.attendease.com/"
          else
            attendease_data_path = File.expand_path("../../_attendease_data", __FILE__)
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

  end
end