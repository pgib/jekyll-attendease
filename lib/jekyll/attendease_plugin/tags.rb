module Jekyll
  module AttendeasePlugin
    class ScheduleWidgetTag < Liquid::Tag
      def render(context)
        schedule_data = ScheduleDataParser.new(context.registers[:site])
        base = File.join(context.registers[:site].config['source'])

        instances = schedule_data.sessions.inject([]) do |memo, s|
          s['instances'].each do |instance|
            instance['session'] = s
            memo << instance
          end
          memo
        end
        instances.sort!{|x,y| [x['time'], x['session']['name']] <=> [y['time'], y['session']['name']]}

        source_template_path = File.join(base, '_attendease', 'templates', 'schedule', 'widget.html')

        Liquid::Template.parse(File.read(source_template_path)).render('instances' => instances, 'filters' => schedule_data.filters)
      end
    end

    class AuthScriptTag < Liquid::Tag
      def render(context)
        api_host = context.registers[:site].config['attendease']['api_host']
        '<script type="text/javascript" src="' + api_host + 'assets/attendease_event/auth.js"></script>'
      end
    end

    class SchedulerScriptTag < Liquid::Tag
      def render(context)
        api_host = context.registers[:site].config['attendease']['api_host']
        '<script type="text/javascript" src="' + api_host + 'assets/attendease_event/schedule.js"></script>'
      end
    end

    class LocalesScriptTag < Liquid::Tag
      def render(context)
        locale = context.registers[:site].config['attendease']['locale']
        '<script type="text/javascript">String.locale="' + locale + '";String.toLocaleString("/api/lingo.json");</script>'
      end
    end

    class TranslateTag < Liquid::Tag
      def initialize(tag_name, params, tokens)
        super
        args = split_params(params)
        @key = args.shift
        @options = { 't_size' => 0 }
        if args.length
          args.each do |a|
            match = a.match(/^(.+):\s*(.+)$/)
            @options[match[1]] = match[2].to_i if match
          end
        end
      end

      def split_params(params)
        params.split(",").map(&:strip)
      end

      def render(context)
        I18n::Backend::Simple.include(I18n::Backend::Pluralization)
        I18n.enforce_available_locales = false
        i18n_path = File.join(context.registers[:site].config['source'], '_attendease', 'data', 'lingo.yml')
        I18n.load_path << i18n_path unless I18n.load_path.include?(i18n_path)
        I18n.locale = context.registers[:page]['lang'] || context.registers[:site].config['attendease']['locale'] || context.registers[:site].config['attendease']['lang'] || :en
        I18n.t(@key, :count => @options['t_size'])
      end
    end

    class AuthAccountTag < Liquid::Tag
      def render(context)
        '<div id="attendease-auth-account"></div>'
      end
    end

    class AuthActionTag < Liquid::Tag
      def render(context)
        '<div id="attendease-auth-action"></div>'
      end
    end
  end
end

