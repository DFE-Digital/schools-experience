require 'rails_helper'

describe TextFormattingHelper, type: :helper do
  describe '#safe_format' do
    subject { safe_format content }

    context 'with new lines' do
      let(:content) { "hello\r\n\r\nworld" }
      it { is_expected.to eql "<p>hello</p>\n\n<p>world</p>" }
    end

    context 'with html content' do
      let(:content) { "<strong>hello</strong> <em>world</em>" }
      it { is_expected.to eql "<p>hello world</p>" }
    end
  end

  describe '#conditional_format' do
    subject { conditional_format content }

    context "with new lines" do
      let(:content) { "foo\nbar" }
      it { is_expected.to eql "<p>foo\n<br />bar</p>" }
    end

    context "without new lines" do
      let(:content) { "foobar" }
      it { is_expected.to eql "foobar" }
    end
  end
end
