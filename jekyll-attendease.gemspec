Gem::Specification.new do |s|
  s.name        = 'jekyll-attendease'
  s.version     = '0.4.0'
  s.date        = '2013-10-07'
  s.summary     = "Attendease event helper for Jekyll"
  s.description = "Bring your event data into Jekyll for amazing event websites."
  s.authors     = ["Michael Wood", "Patrick Gibson", "Jamie Lubiner"]
  s.email       = 'support@attendease.com'
  s.files       = ["README.md", "lib/jekyll-attendease.rb", "assets/auth_check.js", "templates/layout.html", "templates/attendease_schedule_day_sessions.html", "templates/_includes/attendease/filter.html", "templates/_includes/attendease/presenter_item.html", "templates/_includes/attendease/session_instance_item.html"]
  s.homepage    = 'https://attendease.com/'

  s.add_dependency 'httparty'
  s.add_dependency 'json'
end
