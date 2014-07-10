module Jekyll
  module AttendeasePlugin
    class EventDataGenerator < ::Jekyll::Generator
      safe true

      priority :highest

      include HTTParty

      def get(url, options = {})
        begin
          self.class.get(url, options)
        rescue => e
          Jekyll.logger.error "Could not connect to #{url}."
          puts e.inspect
        end
      end

      def self.parameterize(source, sep = '-')
        return '' if source.nil?
        string = source.downcase
        # Turn unwanted chars into the separator
        string.gsub!(/[^a-z0-9\-_]+/, sep)
        unless sep.nil? || sep.empty?
          re_sep = Regexp.escape(sep)
          # No more than one of the separator in a row.
          string.gsub!(/#{re_sep}{2,}/, sep)
          # Remove leading/trailing separator.
          string.gsub!(/^#{re_sep}|#{re_sep}$/, '')
        end
        string
      end

      def use_cache?(file)
        (Time.now.to_i - File.mtime(file).to_i) <= (@attendease_config['cache_expiry'].nil? ? 30 : @attendease_config['cache_expiry'])  # file is less than 30 seconds old
      end

      def generate(site)
        if @attendease_config = site.config['attendease']
          if @attendease_config['api_host'] && !@attendease_config['api_host'].match(/^http/)
            raise "Is your Attendease api_host site properly in _config.yml? Needs to be something like https://myevent.attendease.com/"
          else
            # add a trailing slash if we are missing one.
            if @attendease_config['api_host'][-1, 1] != '/'
              @attendease_config['api_host'] += '/'
            end

            @attendease_data_path = File.join(site.source, '_attendease', 'data')

            FileUtils.mkdir_p(@attendease_data_path)

            data_files = %w{ site event sessions presenters rooms filters venues sponsors }.map { |m| "#{m}.json"} << 'lingo.yml'

            data_files.each do |file_name|
              update_data = true

              file = File.join(@attendease_data_path, file_name)
              if File.exists?(file) && use_cache?(file)
                update_data = false

                if file_name.match(/json$/)
                  begin
                    data = JSON.parse(File.read(file))
                  rescue => e
                    raise "Error parsing #{file}: #{e.inspect}"
                  end
                else
                  data = File.read(file)
                end
              end

              key = "has_#{file_name.split('.')[0]}"

              # don't bother making a request for resources that don't exist in the event
              if !@attendease_config[key].nil? && !@attendease_config[key]
                update_data = false
                data = []
              end

              if update_data
                options = {}
                options.merge!(:headers => {'X-Event-Token' => @attendease_config['access_token']}) if @attendease_config['access_token']

                request_filename = file_name.gsub(/yml$/, 'yaml')
                data = get("#{@attendease_config['api_host']}api/#{request_filename}", options)

                #if (file_name.match(/yaml$/) || data.is_a?(Hash) && !data['error']) || data.is_a?(Array)
                if (!data.nil? && data.response.is_a?(Net::HTTPOK))
                  Jekyll.logger.info "[Attendease] Saving #{file_name} data..."

                  if file_name.match(/json$/)
                    File.open(file, 'w+') { |f| f.write(data.parsed_response.to_json) }
                  else
                    File.open(file, 'w+') { |f| f.write(data.body) }
                  end
                else
                  raise "Request failed for #{@attendease_config['api_host']}api/#{request_filename}. Is your Attendease api_host site properly in _config.yml?"
                end
              end

              if file_name == 'site.json'
                # Adding to site config so we can access these variables globally wihtout using a Liquid Tag so we can use if/else
                site.config['attendease']['data'] = {}

                data.keys.each do |tag|
                  site.config['attendease']['data'][tag] = data[tag]
                  # memorandum from the department of redundancy department:
                  # --------------------------------------------------------
                  # support accessing the attendease_* variables without the
                  # attendease_ prefix because they're already namespaced in
                  # site.attendease.data
                  #
                  # TODO: update all themes to not use attendease_ variables
                  #       and then retire them from the ThemeManager.
                  if tag.match(/^attendease_/)
                    site.config['attendease']['data'][tag.gsub(/^attendease_/, '')] = data[tag]
                  end
                end
              elsif file_name == 'event.json'
                site.config['attendease']['event'] = {}

                data.keys.each do |tag|
                  site.config['attendease']['event'][tag] = data[tag]
                end
              end
            end

            # Generate the template files if they don't yet exist.
            %w{ schedule presenters venues sponsors}.each do |p|
              path = File.join(site.source, '_attendease', 'templates', p)
              FileUtils.mkdir_p(path)
              raise "Could not create #{path}." unless File.exists?(path)
            end

            template_path = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'templates', '_includes', 'attendease'))
            files_to_create_if_they_dont_exist = Dir.chdir(template_path) { Dir.glob('*/**.html') }

            files_to_create_if_they_dont_exist.each do |file|
              destination_file = File.join(site.source, '_attendease', 'templates', file)
              FileUtils.cp(File.join(template_path, file), destination_file) unless File.exists?(destination_file)
            end

            # make the event available to anyone
            event = JSON.parse(File.read("#{@attendease_data_path}/event.json"))
            site.config['attendease']['event'] = event
          end

        else
          raise "Please set the Attendease event data in your _config.yml"
        end
      end
    end
  end
end
