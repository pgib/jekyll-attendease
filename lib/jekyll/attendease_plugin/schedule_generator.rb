module Jekyll
  module AttendeasePlugin
    class ScheduleGenerator < Generator
      safe true

      def generate(site)
        if site.config['attendease'] && site.config['attendease']['api_host'] && site.config['attendease']['generate_schedule_pages']

          # Fetch all the session data!
          attendease_api_host = site.config['attendease']['api_host']
          attendease_access_token = site.config['attendease']['access_token']

          attendease_data_path = "#{site.source}/_attendease_data"

          event = site.config['attendease']['event']

          sessions = JSON.parse(File.read("#{attendease_data_path}/sessions.json")).sort{|s1, s2| s1['name'] <=> s2['name']}
          presenters = JSON.parse(File.read("#{attendease_data_path}/presenters.json")).sort{|p1, p2| p1['last_name'] <=> p2['last_name']}
          rooms = JSON.parse(File.read("#{attendease_data_path}/rooms.json")).sort{|r1, r2| r1['name'] <=> r2['name']}
          filters = JSON.parse(File.read("#{attendease_data_path}/filters.json")).sort{|f1, f2| f1['name'] <=> f2['name']}
          venues = JSON.parse(File.read("#{attendease_data_path}/venues.json")).sort{|v1, v2| v1['name'] <=> v2['name']}

          sessions = Jekyll::Attendease::sessions_with_all_data(event, sessions, presenters, rooms, venues, filters)

          # /schedule pages.
          dir = site.config['attendease']['schedule_path_name']

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
          dir = site.config['attendease']['presenters_path_name']

          presenters.each do |presenter|
            presenter['slug'] = EventData.parameterize("#{presenter['first_name']} #{presenter['last_name']}", '_') + '.html'
            site.pages << PresenterPage.new(site, site.source, File.join(dir, presenter['slug']), presenter, sessions)
          end

          site.pages << PresentersIndexPage.new(site, site.source, File.join(dir), presenters)

          # /venue pages.
          dir = (site.config['attendease'] && site.config['attendease']['venues_path_name']) ? site.config['attendease']['venues_path_name'] : 'venues'

          venues.each do |venue|
            venue['slug'] = EventData.parameterize(venue['name'], '_') + '.html'
            site.pages << VenuePage.new(site, site.source, File.join(dir, venue['slug']), venue)
          end

          site.pages << VenuesIndexPage.new(site, site.source, File.join(dir), venues)
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

