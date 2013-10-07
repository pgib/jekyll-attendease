require 'httparty'
require 'json'

module Jekyll
  module Attendease

    class EventData < Generator
      safe true

      priority :highest

      include HTTParty

      def get(url, options = {})
        begin
          self.class.get(url, options)
        rescue => e
          puts "Could not connect to #{url}."
          puts e.inspect
        end
      end

      def generate(site)
        if @attendease_config = site.config['attendease']

          if @attendease_config['api_host'] && !@attendease_config['api_host'].match(/^http(.*).attendease.com/)
            raise "Is your Attendease api_host site properly in _config.yml? Needs to be something like https://myevent.attendease.com/"
          else
            # add a trailing slash if we are missing one.
            if @attendease_config['api_host'][-1, 1] != '/'
              @attendease_config['api_host'] += '/'
            end

            @attendease_data_path = "#{site.source}/_attendease_data"

            FileUtils.mkdir_p(@attendease_data_path)

            data_files = ['site.json', 'event.json', 'sessions.json', 'presenters.json', 'rooms.json', 'filters.json']

            data_files.each do |file_name|
              update_data = true

              if File.exists?("#{@attendease_data_path}/#{file_name}")
                if (Time.now.to_i - File.mtime("#{@attendease_data_path}/#{file_name}").to_i) <= (@attendease_config['cache_expiry'].nil? ? 30 : @attendease_config['cache_expiry'])  # file is less than 30 seconds old
                  update_data = false

                  site_json = File.read("#{@attendease_data_path}/#{file_name}")

                  data = JSON.parse(site_json)
                end
              end

              if update_data
                options = {}
                options.merge!(:headers => {'X-Event-Token' => @attendease_config['access_token']}) if @attendease_config['access_token']

                data = get("#{@attendease_config['api_host']}api/#{file_name}", options)

                if (data.is_a?(Hash) && !data['error']) || data.is_a?(Array)
                  puts "" if file_name == 'site.json' # leading space, that's all.
                  puts "                    [Attendease] Saving #{file_name} data..."

                  File.open("#{@attendease_data_path}/#{file_name}", 'w+') { |file| file.write(data.parsed_response.to_json) }
                else
                  raise "Event data not found, is your Attendease api_host site properly in _config.yml?"
                end
              end

              if file_name == 'site.json'
                # Adding to site config so we can access these variables globally wihtout using a Liquid Tag so we can use if/else
                site.config['attendease']['data'] = {}

                data.keys.each do |tag|
                  site.config['attendease']['data'][tag] = data[tag]
                end
              end
            end
          end

        else
          raise "Please set the Attendease event data in your _config.yml"
        end
      end
    end

    class EventThemes < Generator
      safe true

      priority :high

      def generate(site)
        puts "                    [Attendease] Generating theme layouts..."

        attendease_precompiled_theme_layouts_path = "#{site.source}/_attendease_layouts"

        FileUtils.mkdir_p(attendease_precompiled_theme_layouts_path)

        layouts_to_precompile = ['layout', 'register', 'schedule', 'presenters']

        # Precompiled layout for website sections.
        layouts_to_precompile.each do |layout|
          if File.exists?("#{site.source}/_layouts/layout.html")

            # create a layout file if is already doesn't exist.
            # the layout file will be used by attendease to wrap /register, /schedule, /presnters in the
            # look the compiled file defines.
            # ensure {{ content }} is in the file so we can render content in there!
            if !File.exists?("#{site.source}/_attendease_layouts/#{layout}.html")
              theme_layout_content = File.read(File.dirname(__FILE__) + "/../templates/layout.html")

              File.open("#{site.source}/_attendease_layouts/#{layout}.html", 'w+') { |file| file.write(theme_layout_content) }
            end
          end

          site.pages << AttendeaseLayoutPage.new(site, site.source, 'attendease_layouts', "#{layout}.html")
        end
      end
    end

    class AttendeaseLayoutPage < Page
      def initialize(site, base, dir, name)
        @site = site
        @base = base
        @dir = dir
        @name = name

        self.process(name)
        self.read_yaml(File.join(base, '_attendease_layouts'), name)
      end
    end

    class AttendeaseAuthScriptTag < Liquid::Tag
      def render(context)
        "<script type=\"text/javascript\">#{File.read(File.dirname(__FILE__) + "/../assets/auth_check.js")}</script>"
      end
    end

    class AttendeaseAuthAccountTag < Liquid::Tag
      def render(context)
        '<div id="attendease-auth-account"></div>'
      end
    end

    class AttendeaseAuthActionTag < Liquid::Tag
      def render(context)
        '<div id="attendease-auth-action"></div>'
      end
    end

    class AttendeaseContent < Liquid::Tag
      def render(context)
        "{{ content }}"
      end
    end


    class SessionDayPage < Page
      def initialize(site, base, dir, day, sessions, presenters, rooms, filters)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)
        self.read_yaml(File.join(base, '_layouts'), 'attendease_schedule_day_sessions.html')

        session_day_title_prefix = site.config['session_day_title_prefix'] || 'Schedule: '
        self.data['title'] = "#{session_day_title_prefix}#{day['date']}"

        self.data['day'] = day

        instances = []
        sessions.each do |s|
          s['instances'].each do |i|
            if i['date'] == day['date']
              instance = {
                'session' => {
                  'name' => s['name'],
                  'description' => s['description'],
                  'presenters' => s['presenters'],
                  'filters' => s['filters']
                },

                'time' => i['time'],
                'duration' => i['duration'],
              }

              room =  rooms.select{|room| room['id'] == i['room_id'] }.first

              instance['room'] = {
                'name' => room['name'],
                'capacity' => room['capacity']
              }

              instances << instance
            end
          end
        end

        self.data['instances'] = instances
      end
    end

    class AttendeaseScheduleGenerator < Generator
      safe true

      def generate(site)
        if site.config['attendease'] && site.config['attendease']['api_host'] && site.config['attendease']['generate_schedule_pages']

          # Fetch all the session data!
          attendease_api_host = site.config['attendease']['api_host']
          attendease_access_token = site.config['attendease']['access_token']

          options = {}
          options.merge!(:headers => {'X-Event-Token' => attendease_access_token}) if attendease_access_token

          event = HTTParty.get("#{attendease_api_host}/api/event.json", options).parsed_response
          sessions = HTTParty.get("#{attendease_api_host}/api/sessions.json", options).parsed_response
          presenters = HTTParty.get("#{attendease_api_host}/api/presenters.json", options).parsed_response
          rooms = HTTParty.get("#{attendease_api_host}/api/rooms.json", options).parsed_response
          filters = HTTParty.get("#{attendease_api_host}/api/filters.json", options).parsed_response

          sessions = sessions_with_presenters_and_filters(sessions, presenters, filters)

          if !site.layouts.key? 'attendease_schedule_day_sessions'
            # Generate the schedule day page layout file if it doesn't exist.
            layout_file = File.read(File.join(File.dirname(__FILE__), '..', '/templates/attendease_schedule_day_sessions.html'))
            File.open(File.join(site.source, '_layouts/attendease_schedule_day_sessions.html'), 'w+') { |out_file| out_file.write(layout_file) }
          end

          # Generate the schedule day page include files if they don't yet exist.
          files_to_create_if_they_dont_exist = [ 'filter.html', 'presenter_item.html', 'session_instance_item.html']
          files_to_create_if_they_dont_exist.each do |file|
            FileUtils.mkdir_p("#{site.source}/_includes/attendease")

            if !File.exists?(File.join(site.source, '_includes/attendease/', file))
              include_file = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', file))
              File.open(File.join(site.source, '_includes/attendease/', file), 'w+') { |out_file| out_file.write(include_file) }
            end
          end

          dir = (site.config['attendease'] && site.config['attendease']['schedule_path_name']) ? site.config['attendease']['schedule_path_name'] : 'schedule'

          event['dates'].each do |day|
            # get all the sessions for that day!
            site.pages << SessionDayPage.new(site, site.source, File.join(dir, day['date']), day, sessions, presenters, rooms, filters)
          end

        end
      end

      def sessions_with_presenters_and_filters(sessions, presenters, filters)
        sessions_parsed = []

        sessions.each do |session|
          presenters_for_session = presenters.select{|presenter| session['speaker_ids'].include?(presenter['id']) }

          session['presenters'] = presenters_for_session.map do |presenter|
            {
              'first_name' => presenter['first_name'],
              'last_name' => presenter['last_name'],
              'company' => presenter['company'],
              'title' => presenter['title'],
              'profile_url' => presenter['profile_url'],
              'bio' => presenter['bio']
            }
          end

          filters_for_session_hash = {}

          filters.each do |filter|
            filter['filter_items'].each do |filter_item|
              if session['filters'].include?(filter_item['id'])
                filters_for_session_hash[filter['name']] = [] unless filters_for_session_hash[filter['name']]
                filters_for_session_hash[filter['name']] << {
                  'name' => filter_item['name']
                }
              end
            end
          end

          filters_for_session = filters_for_session_hash.map do |key, value|
            {
              'name' => key,
              'items' => value
            }
          end

          session['filters'] = filters_for_session

          sessions_parsed << session
        end

        sessions_parsed
      end
    end


  end
end

Liquid::Template.register_tag('attendease_content', Jekyll::Attendease::AttendeaseContent)
Liquid::Template.register_tag('attendease_auth_script', Jekyll::Attendease::AttendeaseAuthScriptTag)
Liquid::Template.register_tag('attendease_auth_account', Jekyll::Attendease::AttendeaseAuthAccountTag)
Liquid::Template.register_tag('attendease_auth_action', Jekyll::Attendease::AttendeaseAuthActionTag)