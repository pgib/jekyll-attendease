require 'httparty'
require 'json'
require 'i18n'

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

      def self.parameterize(string, sep = '-')
        string.downcase!
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

      def generate(site)
        if @attendease_config = site.config['attendease']

          if @attendease_config['api_host'] && !@attendease_config['api_host'].match(/^http/)
            raise "Is your Attendease api_host site properly in _config.yml? Needs to be something like https://myevent.attendease.com/"
          else
            # add a trailing slash if we are missing one.
            if @attendease_config['api_host'][-1, 1] != '/'
              @attendease_config['api_host'] += '/'
            end

            @attendease_data_path = "#{site.source}/_attendease_data"

            FileUtils.mkdir_p(@attendease_data_path)

            data_files = ['site.json', 'event.json', 'sessions.json', 'presenters.json', 'rooms.json', 'filters.json', 'venues.json', 'lingo.yml']

            data_files.each do |file_name|
              update_data = true

              if File.exists?("#{@attendease_data_path}/#{file_name}")
                if (Time.now.to_i - File.mtime("#{@attendease_data_path}/#{file_name}").to_i) <= (@attendease_config['cache_expiry'].nil? ? 30 : @attendease_config['cache_expiry'])  # file is less than 30 seconds old
                  update_data = false

                  if file_name.match(/json$/)
                    json = File.read("#{@attendease_data_path}/#{file_name}")

                    data = JSON.parse(json)
                  else
                    data = File.read("#{@attendease_data_path}/#{file_name}")
                  end
                end
              end

              if update_data
                options = {}
                options.merge!(:headers => {'X-Event-Token' => @attendease_config['access_token']}) if @attendease_config['access_token']

                request_filename = file_name.gsub(/yml$/, 'yaml')
                data = get("#{@attendease_config['api_host']}api/#{request_filename}", options)

                #if (file_name.match(/yaml$/) || data.is_a?(Hash) && !data['error']) || data.is_a?(Array)
                if (data.response.is_a?(Net::HTTPOK))
                  puts "" if file_name == 'site.json' # leading space, that's all.
                  puts "                    [Attendease] Saving #{file_name} data..."


                  if file_name.match(/json$/)
                    File.open("#{@attendease_data_path}/#{file_name}", 'w+') { |file| file.write(data.parsed_response.to_json) }
                  else
                    File.open("#{@attendease_data_path}/#{file_name}", 'w+') { |file| file.write(data.body) }
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
                end
              elsif file_name == 'event.json'
                site.config['attendease']['event'] = {}

                data.keys.each do |tag|
                  site.config['attendease']['event'][tag] = data[tag]
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

        attendease_precompiled_theme_layouts_path = "#{site.source}/attendease_layouts"

        FileUtils.mkdir_p(attendease_precompiled_theme_layouts_path)

        base_layout = (site.config['attendease'] && site.config['attendease']['base_layout']) ? site.config['attendease']['base_layout'] : 'layout'

        layouts_to_precompile = ['layout', 'register', 'schedule', 'presenters']

        # Precompiled layout for website sections.
        layouts_to_precompile.each do |layout|
          if File.exists?("#{site.source}/_layouts/#{base_layout}.html")

            # create a layout file if it already doesn't exist.
            # the layout file will be used by attendease to wrap /register, /schedule, /presnters in the
            # look the compiled file defines.
            # ensure {{ content }} is in the file so we can render content in there!
            if !File.exists?("#{attendease_precompiled_theme_layouts_path}/#{layout}.html")
              site.pages << AttendeaseLayoutPage.new(site, site.source, 'attendease_layouts', "#{layout}.html", base_layout)
            end
          end
        end
      end
    end

    class AttendeaseLayoutPage < Page
      def initialize(site, base, dir, name, base_layout)
        @site = site
        @base = base
        @dir = dir
        @name = name

        self.process(name)

        self.read_yaml(File.dirname(__FILE__) + "/../templates", 'layout') # a template for the layout.

        self.data['layout'] = base_layout
      end
    end

    class AttendeaseAuthScriptTag < Liquid::Tag
      def render(context)
        api_host = context.registers[:site].config['attendease']['api_host']
        '<script type="text/javascript" src="' + api_host + 'assets/attendease_event/auth.js"></script>'
      end
    end

    class AttendeaseSchedulerScriptTag < Liquid::Tag
      def render(context)
        api_host = context.registers[:site].config['attendease']['api_host']
        '<script type="text/javascript" src="' + api_host + 'assets/attendease_event/schedule.js"></script>'
      end
    end

    class AttendeaseLocalesScriptTag < Liquid::Tag
      def render(context)
        '<script type="text/javascript">String.locale="en";String.toLocaleString("/api/lingo.json");</script>'
      end
    end

    class AttendeaseTranslateTag < Liquid::Tag
      def initialize(tag_name, params, tokens)
        super
        @args = split_params(params)
      end

      def split_params(params)
        params.split(",").map(&:strip)
      end

      def render(context)
        I18n::Backend::Simple.include(I18n::Backend::Pluralization)
        I18n.enforce_available_locales = false
        i18n_path = File.join(context.registers[:site].config['source'], '_attendease_data', 'lingo.yml')
        I18n.load_path << i18n_path unless I18n.load_path.include?(i18n_path)
        I18n.locale = context.registers[:page]['lang'] || context.registers[:site].config['attendease']['lang'] || :en
        I18n.t(@args[0], :count => context['t_size'].nil? ? 0 : context['t_size'].to_i)
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


    class ScheduleIndexPage < Page
      def initialize(site, base, dir, dates)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'schedule.html')

        self.data['title'] = site.config['schedule_index_title_prefix'] || 'Schedule'

        self.data['dates'] = dates

        if File.exists?(File.join(base, '_includes', 'attendease', 'schedule', 'index.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'schedule', 'index.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'schedule/index.html')) # Use template
        end
      end
    end

    class ScheduleDayPage < Page
      def initialize(site, base, dir, day, sessions, dates)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'schedule.html')

        session_day_title_prefix = site.config['schedule_day_title_prefix'] || 'Schedule: '
        self.data['title'] = "#{session_day_title_prefix}#{day['date_formatted']}"

        self.data['day'] = day
        self.data['dates'] = dates

        instances = []

        sessions.each do |s|
          s['instances'].each do |instance|
            if instance['date'] == day['date']
              instance['session'] = s

              instances << instance
            end
          end
        end

        self.data['instances'] = instances.sort{|x,y| [x['time'], x['session']['name']] <=> [y['time'], y['session']['name']]}

        if File.exists?(File.join(base, '_includes', 'attendease', 'schedule', 'day.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'schedule', 'day.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'schedule/day.html')) # Use template
        end
      end
    end

    class ScheduleSessionsPage < Page
      def initialize(site, base, dir, sessions, dates)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'schedule.html')

        self.data['title'] = site.config['schedule_sessions_title_prefix'] || 'Schedule: Sessions'

        sessionsData = []

        self.data['sessions'] = sessions
        self.data['dates'] = dates

        if File.exists?(File.join(base, '_includes', 'attendease', 'schedule', 'sessions.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'schedule', 'sessions.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'schedule/sessions.html')) # Use template
        end
      end
    end

    class ScheduleSessionPage < Page
      def initialize(site, base, dir, session)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'schedule.html')

        schedule_session_title_prefix = site.config['schedule_session_title_prefix'] || 'Schedule: '
        self.data['title'] = "#{schedule_session_title_prefix}#{session['name']}"

        self.data['session'] = session

        if File.exists?(File.join(base, '_includes', 'attendease', 'schedule', 'session.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'schedule', 'session.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'schedule/session.html')) # Use template
        end
      end
    end

    class PresentersIndexPage < Page
      def initialize(site, base, dir, presenters)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'presenters.html')

        self.data['title'] = site.config['presenters_index_title_prefix'] || 'Presenters'

        self.data['presenters'] = presenters

        if File.exists?(File.join(base, '_includes', 'attendease', 'presenters', 'index.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'presenters', 'index.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'presenters/index.html')) # Use template
        end
      end
    end

    class PresenterPage < Page
      def initialize(site, base, dir, presenter, sessions)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'presenters.html')

        self.data['title'] = site.config['presenter_title_prefix'] || presenter['first_name'] + ' ' + presenter['last_name']

        presenter['sessions'] = []

        sessions.each do |session|
          if session['speaker_ids'].include?(presenter['id'])
            presenter['sessions'] << session
          end
        end

        self.data['presenter'] = presenter

        if File.exists?(File.join(base, '_includes', 'attendease', 'presenters', 'presenter.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'presenters', 'presenter.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'presenters/presenter.html')) # Use template
        end
      end
    end


    class VenuesIndexPage < Page
      def initialize(site, base, dir, venues)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'schedule.html')

        self.data['title'] = site.config['venues_index_title_prefix'] || 'Venues'

        self.data['venues'] = venues

        if File.exists?(File.join(base, '_includes', 'attendease', 'venues', 'index.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'venues', 'index.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'venues/index.html')) # Use template
        end
      end
    end

    class VenuePage < Page
      def initialize(site, base, dir, venue)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'schedule.html')

        self.data['title'] = site.config['venue_title_prefix'] || 'Venue'

        self.data['venue'] = venue

        if File.exists?(File.join(base, '_includes', 'attendease', 'venues', 'venue.html'))
          self.content = File.read(File.join(base, '_includes', 'attendease', 'venues', 'venue.html')) # Use theme specific layout
        else
          self.content = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', 'venues/venue.html')) # Use template
        end
      end
    end

    class AttendeaseScheduleGenerator < Generator
      safe true

      def generate(site)
        if site.config['attendease'] && site.config['attendease']['api_host'] && site.config['attendease']['generate_schedule_pages']

          # Fetch all the session data!
          attendease_api_host = site.config['attendease']['api_host']
          attendease_access_token = site.config['attendease']['access_token']

          attendease_data_path = "#{site.source}/_attendease_data"

          event = JSON.parse(File.read("#{attendease_data_path}/event.json"))
          sessions = JSON.parse(File.read("#{attendease_data_path}/sessions.json")).sort{|s1, s2| s1['name'] <=> s2['name']}
          presenters = JSON.parse(File.read("#{attendease_data_path}/presenters.json")).sort{|p1, p2| p1['last_name'] <=> p2['last_name']}
          rooms = JSON.parse(File.read("#{attendease_data_path}/rooms.json")).sort{|r1, r2| r1['name'] <=> r2['name']}
          filters = JSON.parse(File.read("#{attendease_data_path}/filters.json")).sort{|f1, f2| f1['name'] <=> f2['name']}
          venues = JSON.parse(File.read("#{attendease_data_path}/venues.json")).sort{|v1, v2| v1['name'] <=> v2['name']}

          # Generate the template files if they don't yet exist.
          files_to_create_if_they_dont_exist = [
            'schedule/index.html', 'schedule/day.html', 'schedule/sessions.html', 'schedule/session.html',
            'presenters/index.html', 'presenters/presenter.html',
            'venues/index.html', 'venues/venue.html',
          ]

          files_to_create_if_they_dont_exist.each do |file|
            FileUtils.mkdir_p("#{site.source}/_includes/attendease/schedule")
            FileUtils.mkdir_p("#{site.source}/_includes/attendease/presenters")
            FileUtils.mkdir_p("#{site.source}/_includes/attendease/venues")

            if !File.exists?(File.join(site.source, '_includes/attendease/', file))
              include_file = File.read(File.join(File.dirname(__FILE__), '..', '/templates/_includes/attendease/', file))
              File.open(File.join(site.source, '_includes/attendease/', file), 'w+') { |out_file| out_file.write(include_file) }
            end
          end

          sessions = Jekyll::Attendease::sessions_with_all_data(event, sessions, presenters, rooms, venues, filters)

          # /schedule pages.
          dir = (site.config['attendease'] && site.config['attendease']['schedule_path_name']) ? site.config['attendease']['schedule_path_name'] : 'schedule'

          if (site.config['attendease'] && site.config['attendease']['show_day_index'])
            site.pages << ScheduleIndexPage.new(site, site.source, File.join(dir), event['dates'])
          else
            site.pages << ScheduleDayPage.new(site, site.source, File.join(dir), event['dates'].first, sessions, event['dates'])
          end

          site.pages << ScheduleSessionsPage.new(site, site.source, File.join(dir, 'sessions'), sessions, event['dates'])

          event['dates'].each do |day|
            site.pages << ScheduleDayPage.new(site, site.source, File.join(dir, day['date']), day, sessions, event['dates'])
          end

          sessions.each do |session|
            site.pages << ScheduleSessionPage.new(site, site.source, File.join(dir, session['code']), session)
          end

          # /presenters pages.
          dir = (site.config['attendease'] && site.config['attendease']['presenters_path_name']) ? site.config['attendease']['presenters_path_name'] : 'presenters'

          site.pages << PresentersIndexPage.new(site, site.source, File.join(dir), presenters)

          presenters.each do |presenter|
            site.pages << PresenterPage.new(site, site.source, File.join(dir, presenter['id']), presenter, sessions)
          end

          # /venue pages.
          dir = (site.config['attendease'] && site.config['attendease']['venues_path_name']) ? site.config['attendease']['venues_path_name'] : 'venues'

          site.pages << VenuesIndexPage.new(site, site.source, File.join(dir), venues)

          venues.each do |venue|
            site.pages << VenuePage.new(site, site.source, File.join(dir, venue['id']), venue)
          end
        end
      end

    end

    def self.sessions_with_all_data(event, sessions, presenters, rooms, venues, filters)
      sessionsData = []

      sessions.each do |s|
        session = {
          'id' => s['id'],
          'name' => s['name'],
          'description' => s['description'],
          'code' => s['code'],
          'speaker_ids' => s['speaker_ids']
        }

        session['presenters'] = []
        presenters.select{|presenter| s['speaker_ids'].include?(presenter['id'])}.each do |presenter|
          session['presenters'] << {
            'id' => presenter['id'],
            'first_name' => presenter['first_name'],
            'last_name' => presenter['last_name'],
            'company' => presenter['company'],
            'title' => presenter['title'],
            'profile_url' => presenter['profile_url'],
          }
        end

        filters_for_session_hash = {}
        filters.each do |filter|
          filter['filter_items'].each do |filter_item|
            if s['filters'].include?(filter_item['id'])
              filters_for_session_hash[filter['name']] = [] unless filters_for_session_hash[filter['name']]
              filters_for_session_hash[filter['name']] << {
                'name' => filter_item['name']
              }
              if event['primary_filter_id'] && event['primary_filter_id'] == filter['id']
                session['primary_filter_name'] = filter['name']
                session['primary_filter'] = filter_item['name']
              end
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

        filter_tags = []
        filters_for_session.each do |filter|
          item_names = []
          if !filter['items'].nil?
            filter['items'].each do |item|
              filter_tags << EventData.parameterize('attendease-filter-' + filter['name'] + "-" + item['name'])
            end
          end
        end
        session['filter_tags'] = filter_tags.join(" ")

        if s['instances']
          instances = []
          s['instances'].each do |i|
            instance = {
              'id' => i['id'],
              'date' => i['date'],
              'time' => i['time'],
              'end_time' => i['end_time'],
              'duration' => i['duration'],
              'date_formatted' => i['date_formatted'],
              'time_formatted' => i['time_formatted'],
              'end_time_formatted' => i['end_time_formatted'],
              'duration_formatted' => i['duration_formatted'],
              'room_id' => i['room_id'],
            }

            room = rooms.select{|room| room['id'] == i['room_id'] }.first
            venue = venues.select{|venue| venue['id'] == room['venue_id'] }.first

            instance['room'] = {
              'name' => room['name'],
              'venue_id' => room['venue_id'],
              'venue_name' => venue['name'],
              'capacity' => room['capacity']
            }

            instances << instance
          end
          session['instances'] = instances
        else
          session['instances'] = []
        end

        sessionsData << session
      end

      sessionsData
    end

  end
end

Liquid::Template.register_tag('attendease_content', Jekyll::Attendease::AttendeaseContent)
Liquid::Template.register_tag('attendease_auth_script', Jekyll::Attendease::AttendeaseAuthScriptTag)
Liquid::Template.register_tag('attendease_scheduler_script', Jekyll::Attendease::AttendeaseSchedulerScriptTag)
Liquid::Template.register_tag('attendease_locales_script', Jekyll::Attendease::AttendeaseLocalesScriptTag)
Liquid::Template.register_tag('attendease_auth_account', Jekyll::Attendease::AttendeaseAuthAccountTag)
Liquid::Template.register_tag('attendease_auth_action', Jekyll::Attendease::AttendeaseAuthActionTag)
Liquid::Template.register_tag('t', Jekyll::Attendease::AttendeaseTranslateTag)
