require 'spec_helper'

RSpec.describe "Jekyll Attendease filters" do
  let(:context) { { :registers => { :site => @site, :page => {} } } }

  def render(content)
    ::Liquid::Template.parse(content).render({}, context)
  end

  context "{{ 'foo Bar bat' | slugify %}" do
    subject { render("{{ 'foo Bar bat' | slugify }}") }
    it { is_expected.to eq "foo_bar_bat" }
  end
end

