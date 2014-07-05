require 'jekyll'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path('../support', __FILE__) + '/**/*.rb']
  .each { |f| require f }

RSpec.configure do |config|
  config.include FixturesHelpers
  config.extend  FixturesHelpers

  config.disable_monkey_patching!

  config.before(:all) do
    if Gem::Version.new('2') <= Gem::Version.new(Jekyll::VERSION)
      Jekyll.logger.log_level = :warn
    else
      Jekyll.logger.log_level = Jekyll::Stevenson::WARN
    end

    @dest = fixtures_path.join('_site')
    @site = Jekyll::Site.new(Jekyll.configuration({
      'source'               => fixtures_path.to_s,
      'destination'          => @dest.to_s,
      'attendease'           => {
        'api_host'             => 'http://foobar/',
        'test_mode'            => false,
        'locale'               => 'en',
        'schedule_path_name'   => 'schedule',
        'presenters_path_name' => 'presenters',
        'sponsors_path_name'   => 'sponsors',
        'has_sessions'         => false,
        'has_presenters'       => false,
        'has_sponsors'         => true,
        'has_rooms'            => false,
        'has_filters'          => false,
        'has_venues'           => false
      }

    }))

    FileUtils.touch Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', '_attendease_data', '*.*'))

    @dest.rmtree if @dest.exist?
    @site.process
  end

  #config.after(:all) do
    #@dest.rmtree if @dest.exist?
  #end
end
