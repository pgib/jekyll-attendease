Gem::Specification.new do |s|
  s.name        = 'jekyll-attendease'
  s.version     = '0.5.4'
  s.date        = '2014-07-02'
  s.summary     = "Attendease event helper for Jekyll"
  s.description = "Bring your event data into Jekyll for amazing event websites."
  s.authors     = ["Michael Wood", "Patrick Gibson", "Jamie Lubiner"]
  s.email       = 'support@attendease.com'
  s.files       = [
    "README.md",
    "lib/jekyll-attendease.rb",

    "templates/layout.html",

    "templates/_includes/attendease/schedule/index.html",
    "templates/_includes/attendease/schedule/day.html",
    "templates/_includes/attendease/schedule/session.html",
    "templates/_includes/attendease/schedule/sessions.html",

    "templates/_includes/attendease/presenters/index.html",
    "templates/_includes/attendease/presenters/presenter.html",

    "templates/_includes/attendease/venues/index.html",
    "templates/_includes/attendease/venues/venue.html",

    "templates/_includes/attendease/sponsors/index.html",
  ]

  s.homepage    = 'https://attendease.com/'
  s.licenses    = [ 'MIT' ]

  s.add_dependency 'httparty'
  s.add_dependency 'json'
  s.add_dependency 'i18n'
  s.add_dependency 'redcarpet'
end
