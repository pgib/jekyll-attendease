module Jekyll
  module AttendeasePlugin
    class OrganizationDataGenerator < EventDataGenerator
      priority :highest

      def generate(site)
        return unless site.config.organization? && site.config.cms_theme?

        if site.config.attendease['api_host'] && !site.config.attendease['api_host'].match(/^https/)
          raise "Is your Attendease api_host site properly in _config.yml? Needs to be something like https://myorg.attendease.org/"
        else
          # add a trailing slash if we are missing one.
          if site.config.attendease['api_host'][-1, 1] != '/'
            site.config.attendease['api_host'] += '/'
          end

          @attendease_data_path = File.join(site.config['attendease_source'], '_attendease', 'data')

          FileUtils.mkdir_p(@attendease_data_path) unless File.exists?(@attendease_data_path)

          data_files = %w{ pages site_settings }.map { |m| "#{m}.json"}

          data_files.each do |filename|
            update_data = true
            data = nil

            file = File.join(@attendease_data_path, filename)
            if File.exists?(file) && use_cache?(site, file)
              update_data = false

              if filename.match(/json$/)
                begin
                  data = JSON.parse(File.read(file))
                rescue => e
                  raise "Error parsing #{file}: #{e.inspect}"
                end
              else
                data = File.read(file)
              end
            end

            if update_data
              unless site.config.attendease['access_token']
                raise "Missing user access_token in the attendease section of _config.yml"
              end

              options = {}
              options.merge!(:headers => {'X-User-Token' => site.config.attendease['access_token']})

              response = get("#{site.config.attendease['api_host']}api/#{filename}", options)

              if (!response.nil? && response.response.is_a?(Net::HTTPOK))
                Jekyll.logger.info "[Attendease] Saving #{filename} data..."

                if filename.match(/json$/)
                  data = response.parsed_response
                  File.open(file, 'w') { |f| f.write(data.to_json) }
                else # yaml
                  File.open(file, 'w') { |f| f.write(response.body) }
                end
              else
                case response.code
                when 403
                  raise "#{response.code} Access token invalid for #{site.config.attendease['api_host']}api/#{filename}"
                else
                  raise "#{response.code} Request failed for #{site.config.attendease['api_host']}api/#{filename}. Is your Attendease api_host site properly in _config.yml?"
                end
              end
            end

            site.data[File.basename(filename, '.*')] = data
          end
        end
      end
    end
  end
end


