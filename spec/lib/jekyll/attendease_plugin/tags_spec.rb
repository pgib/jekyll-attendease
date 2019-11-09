require 'spec_helper'

RSpec.describe "Jekyll Attendease tags" do
  let(:site) { build_site }
  let(:cms_site) { build_site({ 'attendease' => { 'jekyll33' => true } }) }
  let(:context) { { :registers => { :site => site, :page => {} } } }
  let(:cms_context) { { :registers => { :site => cms_site, :page => {} } } }
  let(:org_site) { build_org_site }
  let(:org_context) { { :registers => { :site => org_site, :page => {} } } }

  def render(content)
    ::Liquid::Template.parse(content).render({}, context)
  end

  def cms_render(content)
    ::Liquid::Template.parse(content).render({}, cms_context)
  end

  def org_render(content)
    ::Liquid::Template.parse(content).render({}, org_context)
  end

  context "{% attendease_auth_script %}" do
    subject { render("{% attendease_auth_script %}") }
    it { is_expected.to include "assets/attendease_event/auth.js" }
  end

  context "{% attendease_scheduler_script %}" do
    subject { render("{% attendease_scheduler_script %}") }
    it { is_expected.to include "assets/attendease_event/schedule.js" }
  end

  context "{% attendease_locales_script %}" do
    subject { render("{% attendease_locales_script %}") }
    it { is_expected.to include "/api/lingo.json" }
    it { is_expected.to include site.config['attendease']['api_host'] }
  end

  context "{% attendease_t event.lingo.sponsors %}" do
    subject { render("{% attendease_t event.lingo.sponsors %}") }
    it { is_expected.to eq "Sponsors" }
  end

  context "{% attendease_t event.lingo.sponsors, t_size: 1 %}" do
    subject { render("{% attendease_t event.lingo.sponsors, t_size: 1 %}") }
    it { is_expected.to eq "Sponsor" }
  end

  context "{% attendease_auth_account %}" do
    subject { render("{% attendease_auth_account %}") }
    it { is_expected.to eq '<div id="attendease-auth-account"></div>' }
  end

  context "{% attendease_auth_action %}" do
    subject { render("{% attendease_auth_action %}") }
    it { is_expected.to eq '<div id="attendease-auth-action"></div>' }
  end

  context "{% attendease_schedule_widget %}" do
    subject { render("{% attendease_schedule_widget %}") }
    #{ is_expected.to eq schedule_widget_data }
    it 'should render the correct html' do
      # lines and spaces were giving me issues. Just check if the html is equal.
      expect(subject.gsub(' ', '').gsub("\n", '')).to eq(schedule_widget_data.gsub(' ', '').gsub("\n", ''))
    end
  end

  context "{% attendease_nav %}" do
    subject { render("{% attendease_nav %}{% raw %}<li><a href=\"{{ page.href }}\">{{ page.name }}</a></li>{% endraw %}{% endattendease_nav %}") }
    it { is_expected.to match(/<li><a href="\/agenda\/"/) }

    # hidden page
    it { is_expected.to_not match(/<li><a href="\/test\/"/) }
  end

  context "{% attendease_portal_nav %}" do
    subject { cms_render("{% attendease_portal_nav %}{% raw %}<li><a href=\"{{ page.href }}\">{{ page.name }}</a></li>{% endraw %}{% endattendease_portal_nav %}") }
    it { is_expected.to match(/<li><a href="\/"/) }

    # hidden page
    it { is_expected.to_not match(/<li><a href="\/test\/"/) }
  end

  context "{% attendease_block_renderer %} for event" do
    subject { render("{% attendease_block_renderer %}") }

    it { is_expected.to match(/locale: "en"/) }
    it { is_expected.to match(/siteName: "My Attendease Test Event"/) }
    it { is_expected.to match(/eventApiEndpoint: "https:\/\/foobar\/api"/) }
    it { is_expected.to match(/eventId: "foobar"/) }
    it { is_expected.to match(/orgURL: "https:\/\/foobar.org\/"/) }
    it { is_expected.to match(/orgId: "batbaz"/) }
    it { is_expected.to match(/authApiEndpoint: "https:\/\/foobar.auth\/api"/) }
    it { is_expected.to match(/cdn.attendease.com\/blockrenderer\/latest.js/) }
    it { is_expected.to_not match(/orgLocales/) }
  end

  context "{% attendease_block_renderer %} with custom bundle URL" do
    subject { render("{% attendease_block_renderer https://foobar.cdn/blockrenderer.js %}") }

    it { is_expected.to match(/https:\/\/foobar.cdn\/blockrenderer.js/) }
  end

  context "{% attendease_block_renderer %} for an org portal" do
    subject { org_render("{% attendease_block_renderer %}") }

    it { is_expected.to match(/locale: "en"/) }
    it { is_expected.to match(/siteName: "Foo Bar Widgets"/) }
    it { is_expected.to match(/orgURL: "https:\/\/foobar\/"/) }
    it { is_expected.to match(/orgId: "foobar"/) }
    it { is_expected.to match(/authApiEndpoint: "https:\/\/foobar.auth\/api"/) }
    it { is_expected.to match(/cdn.attendease.com\/blockrenderer\/latest.js/) }
    it { is_expected.to match(/orgLocales: \["en","fr","it","es","de"\]/) }

    it { is_expected.to_not match(/eventApiEndpoint/) }
    it { is_expected.to_not match(/eventId/) }
  end

  describe "{% attendease_analytics_gtm_head %}" do
    subject { cms_render("{% attendease_analytics_gtm_head %}") }

    it { is_expected.to match(/Google Tag Manager/) }
    it { is_expected.to match(/foo/) }
  end

  describe "{% attendease_analytics_gtm_body %}" do
    subject { cms_render("{% attendease_analytics_gtm_body %}") }

    it { is_expected.to match(/Google Tag Manager \(noscript\)/) }
    it { is_expected.to match(/foo/) }
  end

  describe "{% attendease_analytics_ga_gtag %}" do
    subject { cms_render("{% attendease_analytics_ga_gtag %}") }

    it { is_expected.to match(/Global Site Tag \(gtag.js\)/) }
    it { is_expected.to match(/js\?id=google_analytics/) }
    it { is_expected.to match(/gtag\('config'\, 'google_analytics'\)/) }
    it { is_expected.to match(/gtag\('config'\, 'adwords'\)/) }
  end

  describe "{% attendease_analytics_linked_in %}" do
    subject { cms_render("{% attendease_analytics_linkedin %}") }

    it { is_expected.to match(/_linkedin_partner_id = "foo";/) }
    it { is_expected.to match(/foo/) }
  end

  describe "{% attendease_analytics_facebook %}" do
    subject { cms_render("{% attendease_analytics_facebook %}") }

    it { is_expected.to match(/Facebook Pixel Code/) }
    it { is_expected.to match(/foo/) }
  end

  describe "{% attendease_analytics_settings %}" do
    subject { cms_render("{% attendease_analytics_settings %}") }

    it { is_expected.to match(/Global Analytics Settings/) }
    it { is_expected.to match(/googleAnalyticsTrackingId: "google_analytics"/) }
    it { is_expected.to match(/window.AnalyticsSettings = /) }
  end

  describe "{% attendease_sentry %}" do
    subject { cms_render("{% attendease_sentry %}") }

    it { is_expected.to match(/https:\/\/browser.sentry-cdn.com\/5.2.0\/bundle.min.js/) }
    it { is_expected.to match(/dsn: 'https:\/\/foobar@sentry.io\/baz'/) }
  end
end

def schedule_widget_data
<<eos
<div class="attendease-schedule-widget">

    <div class="attendease-date" data-date="2014-07-08" data-date-id="000000000000000000abcdef">
      July 8, 2014
    </div>

        <div class="attendease-session-and-instance attendease-filter-foo-bar" data-instance-id="53bc13b702c8bc9994000056" data-session-id="53bc133102c8bc9994000053">
          <div class="attendease-instance-details">
            <div class="attendease-instance-detail attendease-time-range" data-duration="60" data-start-time="08:45">
              08:45 - 09:45

              <div class="attendease-duration" data-duration="60">
                1 hour
              </div>
            </div>
          </div>
          <div class="attendease-name">
            Swimming 101
          </div>
        </div>

        <div class="attendease-session-and-instance attendease-filter-foo-bar" data-instance-id="53bc13b702c8bc9994000057" data-session-id="53bc133102c8bc9994000054">
          <div class="attendease-instance-details">
            <div class="attendease-instance-detail attendease-time-range" data-duration="60" data-start-time="10:45">
              10:45 - 11:45

              <div class="attendease-duration" data-duration="60">
                1 hour
              </div>
            </div>
          </div>
          <div class="attendease-name">
            Swimming 102
          </div>
        </div>

    <div class="attendease-date" data-date="2014-07-09" data-date-id="000000000000000000abcdeg">
      July 9, 2014
    </div>

        <div class="attendease-session-and-instance attendease-filter-foo-bar" data-instance-id="53bc13b702c8bc9994000058" data-session-id="53bc133102c8bc9994000055">
          <div class="attendease-instance-details">
            <div class="attendease-instance-detail attendease-time-range" data-duration="60" data-start-time="08:45">
              08:45 - 09:45

              <div class="attendease-duration" data-duration="60">
                1 hour
              </div>
            </div>
          </div>
          <div class="attendease-name">
          פתיחה וברכות
          </div>
        </div>
</div>
eos
end
