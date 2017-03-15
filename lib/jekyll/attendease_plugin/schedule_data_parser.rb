module Jekyll
  module AttendeasePlugin
    class ScheduleDataParser

      attr_accessor :site

      def initialize(site)
        @site = site
      end

      def event
        site.config['attendease']['event']
      end

      def presenters
        @presenters ||= raw_presenters.each do |presenter|
          slug = Helpers.parameterize("#{presenter['first_name']} #{presenter['last_name']}")
          if slug == ''
            presenter['slug'] = presenter['id'] + '.html'
          else
            presenter['slug'] = slug + '.html'
          end
        end
      end

      def venues
        @venues ||= raw_venues.each do |venue|
          slug = Helpers.parameterize(venue['name'])
          if slug == ''
            venue['slug'] = venue['id'] + '.html'
          else
            venue['slug'] = slug + '.html'
          end
        end
      end

      def rooms
        raw_rooms
      end

      def sessions
        @sessions ||= begin
          raw_sessions.each do |session|
            slug = Helpers.parameterize(session['name'])
            if site.config['attendease']['session_slug_uses_code'] || slug == ''
              session['slug'] = session['code'] + '.html'
            else
              session['slug'] = slug + '.html'
            end
          end
          populate_sessions_with_related_data!(raw_sessions)
        end
      end

      def filters
        raw_filters
      end

      protected

      def raw_presenters
        @raw_presenters ||= @site.data['presenters'].sort{|p1, p2| p1['last_name'] <=> p2['last_name']}
      end

      def raw_venues
        @raw_venues ||= @site.data['venues'].sort{|v1, v2| v1['name'] <=> v2['name']}
      end

      def raw_rooms
        @raw_rooms ||= @site.data['rooms'].sort{|r1, r2| r1['name'] <=> r2['name']}
      end

      def raw_sessions
        @raw_sessions ||= @site.data['sessions'].sort{|s1, s2| s1['name'] <=> s2['name']}
      end

      def raw_filters
        @raw_filters ||= @site.data['filters'].sort{|f1, f2| f1['name'] <=> f2['name']}
      end

      def data_path
        File.join(site.config['source'], '_attendease', 'data')
      end

      def populate_sessions_with_related_data!(sessions)
        sessions.inject([]) do |memo, s|
          session = s.select do |k, v|
            %w{ id name description code speaker_ids slug }.include?(k)
          end

          session['presenters'] = get_session_presenters(s)
          populate_session_filters!(session, s)
          session['instances'] = get_session_instances(s)

          memo << session
        end
      end

      def get_session_presenters(session)
        session_presenters = presenters.select do |presenter|
          session['speaker_ids'].include?(presenter['id'])
        end

        session_presenters.inject([]) do |memo, presenter|
          memo << presenter.select do |k, v|
            %w{ id first_name last_name company title profile_url featured slug }.include?(k)
          end
        end
      end

      # Populates filter related data into session,
      # from source.
      def populate_session_filters!(session, source)
        filters_for_session_hash = {}
        filters.each do |filter|
          filter['filter_items'].each_with_index do |filter_item, index|
            if source['filters'].include?(filter_item['id'])
              filters_for_session_hash[filter['name']] ||= { :colour => filter['colour'], :items => [] }
              filters_for_session_hash[filter['name']][:items] << {
                'name'   => filter_item['name'],
                'colour' => filter_item['colour'],
                'index'  => index,
              }
              if event['primary_filter_id'] && event['primary_filter_id'] == filter['id']
                session['primary_filter_name'] = filter['name']
                session['primary_filter'] = filter_item['name']
              end
            end
          end
        end

        session['filters'] = filters_for_session_hash.map { |key, value| { 'name' => key, 'items' => value[:items], 'colour' => value[:colour] } }
        session['filter_tags'] = get_session_filter_tags(session['filters'])
      end

      def get_session_filter_tags(session_filters)
        session_filters.inject([]) do |memo, filter|
          filter['items'].each do |item|
            memo << Helpers.parameterize('attendease-filter-' + filter['name'] + "-" + item['name'], '-')
          end
          memo
        end.join(" ")
      end

      def get_session_instances(session)
        session['instances'] ||= []
        session['instances'].inject([]) do |memo, i|
          instance = i.select do |k, v|
            %w{ id date time end_time duration date_formatted time_formatted end_time_formatted duration_formatted room_id }.include?(k)
          end

          if room = rooms.select { |r| r['id'] == i['room_id'] }.first
            venue = venues.select { |v| v['id'] == room['venue_id'] }.first
            instance['room'] = room.merge({ 'venue_name' => venue['name'] })
            instance['venue_slug'] = venue['slug']

            memo << instance
          else
            memo
          end
        end
      end
    end
  end
end
