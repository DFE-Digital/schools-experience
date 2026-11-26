require 'rails_helper'
require Rails.root.join("lib", "notify", "notify_sync")

describe Notify::NotifySync do
  subject do
    described_class.new
  end

  before do
    stub_const(
      'NotifySync::API_KEY',
      ["somekey", SecureRandom.uuid, SecureRandom.uuid].join("-")
    )
    allow(subject).to receive(:client).and_return(NotifyFakeClient.new)
    allow($stdout).to receive(:puts)
  end

  specify "template path should be app/notify/notify_email" do
    expect(described_class::TEMPLATE_PATH).to eql(
      [Rails.root, "app", "notify", "notify_email"]
    )
  end

  context 'when comparing templates' do
    let(:local_templates) { {} }
    let(:remote_templates) { {} }

    before do
      allow(subject).to receive_messages(
        local_templates: local_templates,
        remote_templates: remote_templates
      )
      subject.compare
    end

    context 'when present in both repositories' do
      let(:matching_template_id) { 'aaaaaaaa-bbbb-cccc-dddd-111111111111' }
      let(:matching_template_name) { 'A story about a fox' }

      let(:matching_template_body) do
        <<~BODY.chomp
          The quick brown fox jumped
          over the lazy dog
        BODY
      end
      let(:local_templates) do
        { matching_template_id => matching_template_body }
      end
      let(:remote_templates) do
        {
          matching_template_id => OpenStruct.new(
            id: matching_template_id,
            name: matching_template_name,
            body: matching_template_body
          )
        }
      end

      specify "should state that exact templates match" do
        expect($stdout).to have_received(:puts).with(
          [
            matching_template_id.ljust(18),
            matching_template_name.ljust(40),
            "Matches".ljust(20)
          ].join(' ')
        )
      end
    end

    context 'when missing remote templates' do
      let(:local_only_template_id) { 'aaaaaaaa-bbbb-cccc-dddd-222222222222' }
      let(:local_templates) do
        { local_only_template_id => "The quick brown fox jumped\nover the lazy dog" }
      end

      specify "should state that local-only templates are missing from remote repository" do
        expect($stdout).to have_received(:puts).with(
          [
            local_only_template_id.ljust(18),
            "Unknown".ljust(40),
            "Missing remote template".ljust(20)
          ].join(' ')
        )
      end
    end

    context 'when missing local templates' do
      let(:remote_only_template_id) { 'aaaaaaaa-bbbb-cccc-dddd-333333333333' }
      let(:remote_only_template_name) { 'A story about a fox' }
      let(:remote_templates) do
        {
          remote_only_template_id => OpenStruct.new(
            id: remote_only_template_id,
            name: remote_only_template_name,
            body: "The quick brown fox jumped\nover the lazy dog"
          )
        }
      end

      specify "should state that local-only templates are missing from local repository" do
        expect($stdout).to have_received(:puts).with(
          [
            remote_only_template_id.ljust(18),
            remote_only_template_name.ljust(40),
            "Missing local template".ljust(20)
          ].join(' ')
        )
      end
    end
  end

  context 'when pulling templates' do
    let(:template_id) { 'aaaaaaaa-bbbb-cccc-dddd-444444444444' }
    let(:remote_body) do
      <<~TEMPLATE_FOUR
        The quick orange fox jumped
        over the lazy frog
      TEMPLATE_FOUR
    end

    let(:local_templates) do
      { template_id => "The quick brown fox jumped\nover the lazy dog" }
    end
    let(:remote_templates) do
      {
        template_id => OpenStruct.new(
          id: template_id,
          name: "My - Magic - Template",
          body: remote_body
        )
      }
    end

    before do
      allow(File).to receive(:write)
      allow(subject).to receive_messages(
        local_templates: local_templates,
        remote_templates: remote_templates
      )
      subject.pull
    end

    specify "should write the remote file" do
      expect(File).to have_received(:write).with(
        File.join(
          described_class::TEMPLATE_PATH,
          "my_magic_template.#{template_id}.md"
        ),
        remote_body.chomp
      )
    end
  end
end
