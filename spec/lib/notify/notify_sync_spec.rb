require 'rails_helper'
require Rails.root.join("lib", "notify", "notify_sync")
require 'tmpdir'

describe Notify::NotifySync do
  subject(:notify_sync) do
    described_class.new
  end

  before do
    stub_const(
      'NotifySync::API_KEY',
      ["somekey", SecureRandom.uuid, SecureRandom.uuid].join("-")
    )
    allow($stdout).to receive(:puts)
  end

  specify "template path should be app/notify/notify_email" do
    expect(described_class::TEMPLATE_PATH).to eql(
      [Rails.root, "app", "notify", "notify_email"]
    )
  end

  context 'when comparing templates' do
    let(:template_path) { Pathname.new(Dir.mktmpdir) }
    let(:local_templates) { {} }
    let(:remote_templates) { {} }

    before do
      stub_const('Notify::NotifySync::TEMPLATE_PATH', template_path)
      local_templates.each do |template_id, body|
        File.write(template_path.join("template.#{template_id}.md"), body)
      end
      notify_sync.client = instance_double(
        Notifications::Client,
        get_all_templates: OpenStruct.new(collection: remote_templates.values)
      )
      notify_sync.compare
    end

    after { FileUtils.remove_entry(template_path) }

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
    let(:template_path) { Pathname.new(Dir.mktmpdir) }
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
      stub_const('Notify::NotifySync::TEMPLATE_PATH', template_path)
      local_templates.each do |local_template_id, body|
        File.write(template_path.join("template.#{local_template_id}.md"), body)
      end
      notify_sync.client = instance_double(
        Notifications::Client,
        get_all_templates: OpenStruct.new(collection: remote_templates.values)
      )
      notify_sync.pull
    end

    after { FileUtils.remove_entry(template_path) }

    specify "should write the remote file" do
      expect(File.read(template_path.join("my_magic_template.#{template_id}.md")))
        .to eq(remote_body.chomp)
    end
  end
end
