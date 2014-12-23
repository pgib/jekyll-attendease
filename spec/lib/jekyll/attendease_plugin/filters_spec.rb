require 'spec_helper'

RSpec.describe "Jekyll Attendease filters" do
  let(:page_data) { @page.data['foo'] }

  def render(content)
    ::Liquid::Template.parse(content).render({'page' => @page.data})
  end

  context "{{ 'foo Bar bat' | slugify %}" do
    subject { render("{{ 'foo Bar bat' | slugify }}") }
    it { is_expected.to eq "foo_bar_bat" }
  end

  context "{{ page.foo | json %}" do
    subject { render("{{ page.foo | json }}") }
    it { is_expected.to eq(page_data.to_json) }
  end
end

