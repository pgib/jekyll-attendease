require 'jekyll'
require 'coveralls'
Coveralls.wear!

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

    @template_root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'templates'))
    @dest = fixtures_path.join('_site')

    FileUtils.touch Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', '_attendease', 'data', '*.*'))
    @site = build_site
    @page = Jekyll::Page.new(@site, File.join(File.dirname(__FILE__), 'fixtures'), '', 'page.html')
  end

  def test_dir(*subdirs)
    File.join(File.dirname(__FILE__), *subdirs)
  end

  def dest_dir(*subdirs)
    test_dir('dest', *subdirs)
  end

  def source_dir(*subdirs)
    test_dir('source', *subdirs)
  end

  def build_configs(overrides, base_hash = Jekyll::Configuration::DEFAULTS)
    Jekyll::Utils.deep_merge_hashes(base_hash, overrides)
  end

  def find_generator(generator_class)
    @site.generators.select { |m| m.class == generator_class }.first
  end

  def find_page(page_class, lambda_matcher = false)
    @site.pages.select do |m|
      if m.class == page_class
        match = true
        if lambda_matcher
          match = lambda_matcher.call(m)
        end
        m if match
      end
    end.first
  end

  def site_configuration(overrides = {})
    Jekyll::Utils.deep_merge_hashes(build_configs({
      'source'               => fixtures_path.to_s,
      'destination'          => @dest.to_s,
      'attendease'           => {
        'api_host'                => 'http://foobar/',
        'test_mode'               => false,
        'locale'                  => 'en',
        'schedule_path_name'      => 'schedule',
        'presenters_path_name'    => 'presenters',
        'sponsors_path_name'      => 'sponsors',
        'venue_path_name'         => 'venue',
        'venues_path_name'        => 'venues',
        'base_layout'             => 'layout',
        'generate_schedule_pages' => true,
        'has_sessions'            => true,
        'has_presenters'          => true,
        'has_sponsors'            => false,
        'has_rooms'               => true,
        'has_filters'             => true,
        'has_venues'              => true
      }
    }), overrides)
  end

  def build_site(config = {})
    site = Jekyll::Site.new(site_configuration(config))
    site.process
    site
  end

  config.after(:all) do
    @dest.rmtree if @dest.exist?
    fixtures_path.join('_attendease', 'templates').rmtree if fixtures_path.join('_attendease', 'templates').exist?
    fixtures_path.join('attendease_layouts').rmtree if fixtures_path.join('attendease_layouts').exist?
  end
end
