require 'rails_helper'

describe LinkAndButtonHelper do
  shared_examples 'govuk-styled links and buttons' do |method, tag|
    let(:method) { method }
    let(:tag) { tag }
    let(:path) { candidates_root_path }
    let(:link_text) { 'Continue' }
    subject { helper.send(method, link_text, path) }

    specify 'should create a button link with the appropriate data module' do
      expect(subject).to have_css("#{tag}.govuk-button[data-module='govuk-button']")
    end

    context 'overriding text' do
      let(:custom_text) { 'Proceed' }
      subject { helper.send(method, custom_text, path) }

      specify 'button should contain the provided text' do
        expect(subject).to have_css("#{tag}.govuk-button", text: custom_text)
      rescue RSpec::Expectations::ExpectationNotMetError
        expect(subject).to have_button(custom_text)
      end
    end

    context 'extra attributes' do
      subject { helper.send(method, link_text, path, role: 'button', disabled: true, data: { type: 'XYZ' }) }

      specify 'button should have the extra attributes' do
        expect(subject).to have_css(
          "#{tag}.govuk-button[role='button'][disabled='disabled'][data-type='XYZ'][data-module='govuk-button']"
        )
      end
    end

    context 'extra classes' do
      let(:extra_classes) { %w(pink stripy) }
      subject { helper.send(method, link_text, path, class: extra_classes) }

      specify 'should create a button link with extra provided classes' do
        expect(subject).to have_css("#{tag}.#{extra_classes.join('.')}")
      end
    end

    context 'secondary' do
      subject { helper.send(method, link_text, path, secondary: true) }

      specify 'should create a button link with secondary class' do
        expect(subject).to have_css("#{tag}.govuk-button.govuk-button--secondary")
      end
    end

    context 'warning' do
      subject { helper.send(method, link_text, path, warning: true) }

      specify 'should create a button link with warning class' do
        expect(subject).to have_css("#{tag}.govuk-button.govuk-button--warning")
      end
    end

    context 'blocks' do
      let(:custom_text) { 'Advance' }

      subject { helper.send(method, path) { custom_text } }

      specify 'button should contain the text provided by the block' do
        expect(subject).to have_css("#{tag}.govuk-button", text: custom_text)
      rescue RSpec::Expectations::ExpectationNotMetError
        expect(subject).to have_button(custom_text)
      end
    end
  end

  describe '#govuk_link_to' do
    include_examples 'govuk-styled links and buttons', 'govuk_link_to', 'a'
  end

  describe '#govuk_button_to' do
    include_examples 'govuk-styled links and buttons', 'govuk_button_to', 'input'
  end
end
