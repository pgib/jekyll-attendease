module Jekyll
  module AttendeasePlugin
    class ScheduleGenerator < Generator
      safe true
      attr_reader :event
      attr_reader :sessions
      attr_reader :presenters
      attr_reader :rooms
      attr_reader :filters
      attr_reader :venues

      def generate(site)
        if site.config['attendease'] && site.config['attendease']['api_host'] && site.config['attendease']['generate_schedule_pages']

          # Fetch all the session data!
          attendease_api_host = site.config['attendease']['api_host']
          attendease_access_token = site.config['attendease']['access_token']

          attendease_data_path = File.join(site.source, '_attendease', 'data')

          @event = site.config['attendease']['event']

          sessions = JSON.parse(File.read("#{attendease_data_path}/sessions.json")).sort{|s1, s2| s1['name'] <=> s2['name']}
          @presenters = JSON.parse(File.read("#{attendease_data_path}/presenters.json")).sort{|p1, p2| p1['last_name'] <=> p2['last_name']}
          @rooms = JSON.parse(File.read("#{attendease_data_path}/rooms.json")).sort{|r1, r2| r1['name'] <=> r2['name']}
          @filters = JSON.parse(File.read("#{attendease_data_path}/filters.json")).sort{|f1, f2| f1['name'] <=> f2['name']}
          @venues = JSON.parse(File.read("#{attendease_data_path}/venues.json")).sort{|v1, v2| v1['name'] <=> v2['name']}

          @presenters.each do |presenter|
            presenter['slug'] = Helpers.parameterize("#{presenter['first_name']} #{presenter['last_name']}") + '.html'
          end

          @venues.each do |venue|
            venue['slug'] = Helpers.parameterize(venue['name']) + '.html'
          end

          sessions.each do |session|
            if site.config['attendease']['session_slug_uses_code']
              session['slug'] = session['code'] + '.html'
            else
              session['slug'] = Helpers.parameterize(session['name']) + '.html'
            end
          end

          @sessions = sessions_with_all_data(@event, sessions, @presenters, @rooms, @venues, @filters)

          #
          # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          # /schedule pages.
          dir = site.config['attendease']['schedule_path_name']

          if (site.config['attendease'] && site.config['attendease']['show_day_index'])
            site.pages << ScheduleIndexPage.new(site, site.source, File.join(dir), @event['dates'])
          else
            site.pages << ScheduleDayPage.new(site, site.source, File.join(dir), @event['dates'].first, @sessions, @event['dates'])
          end

          site.pages << ScheduleSessionsPage.new(site, site.source, File.join(dir, 'sessions'), @sessions, @event['dates'])

          @event['dates'].each do |day|
            site.pages << ScheduleDayPage.new(site, site.source, File.join(dir, day['date']), day, @sessions, @event['dates'])
          end

          @sessions.each do |session|
            site.pages << ScheduleSessionPage.new(site, site.source, File.join(dir, 'sessions'), session)
          end

          # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          # /presenters pages.
          dir = site.config['attendease']['presenters_path_name']

          @presenters.each do |presenter|
            site.pages << PresenterPage.new(site, site.source, dir, presenter, @sessions)
          end

          site.pages << PresentersIndexPage.new(site, site.source, File.join(dir), @presenters)

          # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          # /venue pages.
          dir = site.config['attendease']['venues_path_name']

          @venues.each do |venue|
            site.pages << VenuePage.new(site, site.source, dir, venue)
          end

          site.pages << VenuesIndexPage.new(site, site.source, File.join(dir), @venues)
        end
      end

      def sessions_with_all_data(event, sessions, presenters, rooms, venues, filters)
        sessionsData = []

        sessions.each do |s|
          session = s.select { |k, v| %w{ id name description code speaker_ids slug }.include?(k) }
          session['presenters'] = []
          presenters.select{|presenter| s['speaker_ids'].include?(presenter['id'])}.each do |presenter|
            session['presenters'] << presenter.select { |k, v| %w{ id first_name last_name company title profile_url slug }.include?(k) }
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

          filters_for_session = filters_for_session_hash.map { |key, value| { 'name' => key, 'items' => value } }

          session['filters'] = filters_for_session

          filter_tags = []
          filters_for_session.each do |filter|
            item_names = []
            if !filter['items'].nil?
              filter['items'].each do |item|
                filter_tags << Helpers.parameterize('attendease-filter-' + filter['name'] + "-" + item['name'], '-')
              end
            end
          end
          session['filter_tags'] = filter_tags.join(" ")

          if s['instances']
            instances = []
            s['instances'].each do |i|
              instance = i.select { |k, v| %w{ id date time end_time duration date_formatted time_formatted end_time_formatted duration_formatted room_id }.include?(k) }

              room  = rooms.select { |room| room['id'] == i['room_id'] }.first
              venue = venues.select { |venue| venue['id'] == room['venue_id'] }.first
              instance['room'] = room.merge({ 'venue_name' => venue['name'] })
              instance['venue_slug'] = venue['slug']

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
end

