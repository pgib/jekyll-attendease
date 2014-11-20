module Jekyll
  module AttendeasePlugin
    class PresenterPage < Page
      def initialize(site, base, dir, presenter, sessions)
        @site = site
        @base = base
        @dir = dir
        @name = presenter['slug']

        self.process(@name)

        self.read_yaml(File.join(base, '_attendease', 'layouts'), 'presenters.html')

        presenter_page_title = site.config['presenter_page_title'] ? site.config['presenter_page_title'] : 'Presenter: %s'
        self.data['title'] = sprintf(presenter_page_title, presenter['first_name'] + ' ' + presenter['last_name'])

        presenter['sessions'] = []

        sessions.each do |session|
          if session['speaker_ids'].include?(presenter['id'])
            presenter['sessions'] << session
          end
        end

        self.data['presenter'] = presenter

        # Check if Attendease API has a template for this page
        if template = Helpers.get_template(site, 'presenters/presenter')
          # use the template file from the attendease api
          self.content = template
        else
          # use the included template in the gem
          self.content = File.read(File.join(base, '_attendease', 'templates', 'presenters', 'presenter.html'))
        end
      end
    end
  end
end
