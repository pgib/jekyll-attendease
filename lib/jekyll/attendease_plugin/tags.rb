module Jekyll
  module AttendeasePlugin
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
        '<script type="text/javascript">String.locale="en";String.toLocaleString("/api/lingo.json");</script>'
      end
    end

    class TranslateTag < Liquid::Tag
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
        I18n.locale = context.registers[:page]['lang'] || context.registers[:site].config['attendease']['locale'] || context.registers[:site].config['attendease']['lang'] || :en
        I18n.t(@args[0], :count => context['t_size'].nil? ? 0 : context['t_size'].to_i)
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

    class Content < Liquid::Tag
      def render(context)
        "{{ content }}"
      end
    end
  end
end

