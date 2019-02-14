require 'rails_helper'
require File.join(Rails.root, "lib", "notify", "notify_sync")

describe NotifySync do
  subject do
    described_class.new
  end

  specify "template path should be app/notify/notify_email" do
    expect(described_class::TEMPLATE_PATH).to eql(
      [Rails.root, "app", "notify", "notify_email"]
    )
  end

  context 'Comparing templates' do
    context 'Present in both repositories' do
      let(:matching_template_id) { 'aaaaaaaa-bbbb-cccc-dddd-111111111111' }

      before do
        allow(subject).to receive(:local_templates).and_return(
          matching_template_id => <<~TEMPLATE_ONE
            The quick brown fox jumped
            over the lazy dog
          TEMPLATE_ONE
          .chomp,
        )

        allow(subject).to receive(:remote_templates).and_return(
          matching_template_id => OpenStruct.new(
            id: matching_template_id,
            body: <<~TEMPLATE_ONE
              The quick brown fox jumped
              over the lazy dog
            TEMPLATE_ONE
          )
        )
      end

      after { subject.compare }

      specify "should state that exact templates match" do
        expect(STDOUT).to receive(:puts).with("#{matching_template_id} Matches")
      end
    end

    context 'Missing remote templates' do
      let(:local_only_template_id) { 'aaaaaaaa-bbbb-cccc-dddd-222222222222' }

      before do
        allow(subject).to receive(:local_templates).and_return(
          local_only_template_id => <<~TEMPLATE_TWO
            The quick brown fox jumped
            over the lazy dog
          TEMPLATE_TWO
          .chomp,
        )
        allow(subject).to receive(:remote_templates).and_return({})
      end

      after { subject.compare }

      specify "should state that local-only templates are missing from remote repository" do
        expect(STDOUT).to receive(:puts).with("#{local_only_template_id} Missing remote template")
      end
    end

    context 'Missing local templates' do
      let(:remote_only_template_id) { 'aaaaaaaa-bbbb-cccc-dddd-333333333333' }

      before do
        allow(subject).to receive(:local_templates).and_return({})

        allow(subject).to receive(:remote_templates).and_return(
          remote_only_template_id => OpenStruct.new(
            id: remote_only_template_id,
            body: <<~TEMPLATE_THREE
              The quick brown fox jumped
              over the lazy dog
            TEMPLATE_THREE
          )
        )
      end

      after { subject.compare }

      specify "should state that local-only templates are missing from local repository" do
        expect(STDOUT).to receive(:puts).with("#{remote_only_template_id} Missing local template")
      end
    end
  end

  context 'Pulling templates' do
    let(:template_id) { 'aaaaaaaa-bbbb-cccc-dddd-444444444444' }
    let(:remote_body) do
      <<~TEMPLATE_FOUR
        The quick orange fox jumped
        over the lazy frog
      TEMPLATE_FOUR
    end

    before do
      allow(subject).to receive(:local_templates).and_return(
        template_id => <<~TEMPLATE_FOUR
          The quick brown fox jumped
          over the lazy dog
        TEMPLATE_FOUR
        .chomp,
      )

      allow(subject).to receive(:remote_templates).and_return(
        template_id => OpenStruct.new(
          id: template_id,
          name: "My - Magic - Template",
          body: remote_body
        )
      )
    end

    after { subject.pull }

    specify "should write the remote file" do
      expect(File).to receive(:write).with(
        File.join(
          described_class::TEMPLATE_PATH,
          "my_magic_template.#{template_id}.md"
        ),
        remote_body.chomp
      )
    end
  end
end
