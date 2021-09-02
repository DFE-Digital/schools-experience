require 'rails_helper'

class StubModel
  include ActiveModel::Model
end

describe ApplicationHelper, type: :helper do
  let(:given_name) { 'Martin' }
  let(:family_name) { 'Prince' }
  let(:user) do
    OpenIDConnect::ResponseObject::UserInfo.new \
      given_name: given_name,
      family_name: family_name
  end

  context 'Breadcrumbs' do
    let(:args) do
      {
        'page one' => '/page/one',
        'page two' => '/page/two',
        'page three' => '/page/three',
        'page four' => nil
      }
    end
    let(:hyperlink_breadcrumbs) { args.reject { |_k, v| v.nil? } }

    let(:breadcrumb_count) { args.count }
    let(:hyperlink_breadcrumb_count) { hyperlink_breadcrumbs.count }

    before { helper.breadcrumbs = args }
    subject { Nokogiri.parse(helper.breadcrumbs) }

    specify 'the generated list should contain GOV.UK breadcrumb-compliant markup' do
      selector = [
        'nav.govuk-breadcrumbs',
        'ol.govuk-breadcrumbs__list',
        'li.govuk-breadcrumbs__list-item',
        'a.govuk-breadcrumbs__list--link'
      ].join(' > ')
      expect(subject.css(selector)).not_to be_nil
    end

    specify 'it should generate the correct total number of breadcrumbs' do
      selector = 'li.govuk-breadcrumbs__list-item'
      expect(subject.css(selector).count).to eql(breadcrumb_count)
    end

    specify 'it should generate the correct number of breadcrumbs with hyperlinks' do
      selector = 'li.govuk-breadcrumbs__list-item > a.govuk-breadcrumbs__list--link'
      expect(subject.css(selector).count).to eql(hyperlink_breadcrumb_count)
    end

    specify 'breadcrumbs should contain the correct text in the right order' do
      args.keys.each.with_index do |text, i|
        expect(subject.css('li')[i].text).to eql(text)
      end
    end

    specify 'breadcrumbs should contain the correct links in the right order' do
      hyperlink_breadcrumbs.values.each.with_index do |path, i|
        expect(subject.css('li > a')[i]['href']).to eql(path)
      end
    end
  end

  context '#current_user_info_and_logout_link' do
    subject { helper.current_user_info_and_logout_link user }
    context 'when a user is logged in' do
      specify "should contain the person's name and a logout link" do
        expect(subject).to include("#{given_name} #{family_name}")
      end

      specify "should contain a logout link" do
        expect(subject).to have_link('Logout', href: '/schools/session/logout')
      end
    end
  end

  describe '#current_user_full_name' do
    subject { helper.current_user_full_name user }

    context 'when current_user present' do
      specify 'should return the combined given and family names' do
        expect(subject).to eql("#{given_name} #{family_name}")
      end
    end

    context 'when current_user absent' do
      let(:user) { nil }
      specify "should return 'Unknown'" do
        expect(subject).to eql("Unknown")
      end
    end
  end

  describe '#page_heading' do
    context 'with parameter' do
      subject! { page_heading('My Page Title') }
      it { is_expected.to eql('<h1 class="govuk-heading-l">My Page Title</h1>') }
      it { expect(page_title).to eql('My Page Title | DfE School Experience') }
    end

    context 'with block' do
      subject! { page_heading { 'My Page Title' } }
      it { is_expected.to eql('<h1 class="govuk-heading-l">My Page Title</h1>') }
      it { expect(page_title).to eql('My Page Title | DfE School Experience') }
    end

    context 'with custom options' do
      subject! { page_heading('Page Title', class: 'govuk-heading-xl') }
      it { is_expected.to eql('<h1 class="govuk-heading-xl">Page Title</h1>') }
      it { expect(page_title).to eql('Page Title | DfE School Experience') }
    end
  end

  describe "#site_header_path" do
    let(:request) { double('request') }
    let(:path) { double('path') }

    before do
      allow(request).to receive(:path).and_return(path)
    end

    context 'when in schools namespace' do
      it 'returns the schools dashboard path' do
        allow(path).to receive(:start_with?).with('/schools').and_return(true)

        expect(site_header_path).to eql(schools_dashboard_path)
      end
    end

    context 'when not in schools namespace' do
      it 'returns the root path' do
        allow(path).to receive(:start_with?).with('/schools').and_return(false)

        expect(site_header_path).to eql(root_path)
      end
    end
  end

  describe "#govuk_form_for" do
    it "renders a form with GOV.UK form builder" do
      expect(govuk_form_for(StubModel.new, url: "http://test.com") {}).to eq(
        "<form class=\"new_stub_model\" id=\"new_stub_model\" novalidate=\"novalidate\" "\
        "action=\"http://test.com\" accept-charset=\"UTF-8\" method=\"post\"></form>",
      )
    end
  end
end
