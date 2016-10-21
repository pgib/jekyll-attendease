require 'spec_helper'

RSpec.describe "Jekyll Attendease tags" do
  let(:context) { { :registers => { :site => @site, :page => {} } } }

  def render(content)
    ::Liquid::Template.parse(content).render({}, context)
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
    subject { render("{% attendease_nav %}{% raw %}<li><a href=\"/{{ page.slug }}/\">{{ page.name }}</a></li>{% endraw %}{% endattendease_nav %}") }
    it { is_expected.to match(/<li><a href="\/schedule\/"/) }
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
