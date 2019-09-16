require 'rails_helper'

describe ApplicationHelper, type: :helper do
  let(:given_name) { 'Martin' }
  let(:family_name) { 'Prince' }

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
    subject { helper.current_user_info_and_logout_link }
    context 'when a user is logged in' do
      before do
        assign(
          :current_user,
          OpenIDConnect::ResponseObject::UserInfo.new(
            given_name: given_name,
            family_name: family_name
          )
        )
      end

      specify "should contain the person's name and a logout link" do
        expect(subject).to include("#{given_name} #{family_name}")
      end

      specify "should contain a logout link" do
        expect(subject).to have_link('Logout', href: '/schools/session/logout')
      end
    end
  end

  describe '#current_user_full_name' do
    subject { helper.current_user_full_name }

    context 'when current_user present' do
      before do
        assign(
          :current_user,
          OpenIDConnect::ResponseObject::UserInfo.new(
            given_name: given_name,
            family_name: family_name
          )
        )
      end

      specify 'should return the combined given and family names' do
        expect(subject).to eql("#{given_name} #{family_name}")
      end
    end

    context 'when current_user absent' do
      specify "should return 'Unknown'" do
        expect(subject).to eql("Unknown")
      end
    end
  end

  describe '#govuk_link_to' do
    let(:path) { candidates_root_path }
    let(:link_text) { 'Continue' }
    subject { helper.govuk_link_to(link_text, path) }

    specify 'should create a button link with the appropriate data module' do
      expect(subject).to have_css("a.govuk-button[data-module='govuk-button']")
    end

    context 'overriding text' do
      let(:custom_text) { 'Proceed' }
      subject { helper.govuk_link_to(custom_text, path) }

      specify 'button should contain the provided text' do
        expect(subject).to have_css('a.govuk-button', text: custom_text)
      end
    end

    context 'extra attributes' do
      subject { helper.govuk_link_to(link_text, path, role: 'button', disabled: true, data: { type: 'XYZ' }) }

      specify 'button should have the extra attributes' do
        expect(subject).to have_css(
          "a.govuk-button[role='button'][disabled='disabled'][data-type='XYZ'][data-module='govuk-button']",
          text: link_text
        )
      end
    end

    context 'extra classes' do
      let(:extra_classes) { %w(pink stripy) }
      subject { helper.govuk_link_to(link_text, path, class: extra_classes) }

      specify 'should create a button link with extra provided classes' do
        expect(subject).to have_css("a.#{extra_classes.join('.')}")
      end
    end

    context 'secondary' do
      subject { helper.govuk_link_to(link_text, path, secondary: true) }

      specify 'should create a button link with secondary class' do
        expect(subject).to have_css('a.govuk-button.govuk-button--secondary')
      end
    end

    context 'warning' do
      subject { helper.govuk_link_to(link_text, path, warning: true) }

      specify 'should create a button link with warning class' do
        expect(subject).to have_css('a.govuk-button.govuk-button--warning')
      end
    end

    context 'blocks' do
      let(:custom_text) { 'Advance' }

      subject { helper.govuk_link_to(path) { custom_text } }

      specify 'button should contain the text provided by the block' do
        expect(subject).to have_css('a.govuk-button', text: custom_text)
      end
    end
  end
end
