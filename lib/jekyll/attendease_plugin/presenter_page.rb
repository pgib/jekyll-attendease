module Jekyll
  module AttendeasePlugin
    class PresenterPage < Page
      def initialize(site, base, dir, presenter, sessions)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'

        self.process(@name)

        self.read_yaml(File.join(base, 'attendease_layouts'), 'presenters.html')

        presenter_page_title = site.config['presenter_page_title'] ? site.config['presenter_page_title'] : 'Presenter: %s'
        self.data['title'] = sprintf(presenter_page_title, presenter['first_name'] + ' ' + presenter['last_name'])

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
  end
end
