require 'rails_helper'

RSpec.describe "candidates/registrations/personal_informations/_form.html.erb", type: :view do
  let(:email_selector) do
    "input#candidates_registrations_personal_information_email"
  end

  before do
    allow(view).to \
      receive(:candidates_school_registrations_personal_information_path).
      and_return('/stubbed')
  end

  context 'when email address is editable' do
    before do
      render 'candidates/registrations/personal_informations/form',
        personal_information: Candidates::Registrations::PersonalInformation.new
    end

    it "will allow the address to be changed" do
      expect(rendered).to have_css(email_selector, count: 1)
      expect(rendered).to have_css("#{email_selector}[readonly]", count: 0)
      expect(rendered).to have_css("#{email_selector}[disabled]", count: 0)
    end
  end

  context 'when email address is read only' do
    let(:personal_information) do
      Candidates::Registrations::PersonalInformation.new(
        first_name: 'Foo',
        last_name: 'Bar',
        email: 'foo@bar.com',
        read_only_email: true,
        date_of_birth: Date.parse('1980-01-01')
      )
    end

    before do
      render 'candidates/registrations/personal_informations/form',
        personal_information: personal_information
    end

    it "will allow the address to be changed" do
      expect(rendered).to have_css(email_selector, count: 1)
      expect(rendered).to have_css("#{email_selector}[readonly]", count: 1)
      expect(rendered).to have_css("#{email_selector}[disabled]", count: 1)
    end
  end
end
