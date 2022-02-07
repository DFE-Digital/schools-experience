require "rails_helper"
require "school_group"

describe SchoolGroup do
  describe "#in_group?" do
    let(:sample) { described_class::SCHOOL_URNS_IN_GROUP.sample }

    it { expect(described_class).to be_in_group(sample) }
    it { expect(described_class).to be_in_group(sample.to_s) }
    it { expect(described_class).not_to be_in_group(123_456) }
    it { expect(described_class).not_to be_in_group("000000") }
  end
end
