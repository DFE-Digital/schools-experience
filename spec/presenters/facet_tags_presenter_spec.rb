require 'rails_helper'

RSpec.describe FacetTagsPresenter do
  let(:filters) do
    {
      "Group 1" => {
        key_1: [
          { value: 1, text: "One" },
          { value: 2, text: "Two" },
        ],
      },
      "Group 2" => {
        key_2: [{ value: 3, text: "Three" }],
        key_3: [{ value: 4, text: "Four" }],
      },
      "Group 3" => {
        key_5: [{ value: 5, text: "Five" }],
        key_6: [{ value: 6, text: "Six" }, { value: 7, text: "Seven" }],
      },
      "Group 4" => {
        key_6: [],
      },
      "Group 5" => {}
    }
  end

  let(:instance) { described_class.new(filters) }

  describe ".applied_filters" do
    subject { instance.applied_filters }

    # By flattening the filters and adding prepositions we can display
    # them to the user in a way that makes sense, for example:
    #
    # Group 1: One or Two
    # Group 2: Three and Four
    # Group 3: Five and (Six or Seven)
    it do
      is_expected.to eq({
        "Group 1" => [
          { value: 1, text: "One", key: "key-1" },
          { value: 2, text: "Two", preposition: :or, key: "key-1" },
        ],
        "Group 2" => [
          { value: 3, text: "Three", key: "key-2" },
          { value: 4, text: "Four", preposition: :and, key: "key-3" },
        ],
        "Group 3" => [
          { value: 5, text: "Five", key: "key-5" },
          { value: 6, text: "Six", preposition: :and, key: "key-6" },
          { value: 7, text: "Seven", preposition: :or, key: "key-6" },
        ]
      })
    end
  end
end
