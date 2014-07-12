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

  context "{% t event.lingo.sponsors %}" do
    subject { render("{% t event.lingo.sponsors %}") }
    it { is_expected.to eq "Sponsors" }
  end

  context "{% t event.lingo.sponsors, t_size: 1 %}" do
    subject { render("{% t event.lingo.sponsors, t_size: 1 %}") }
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
end

