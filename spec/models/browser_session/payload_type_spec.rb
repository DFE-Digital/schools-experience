require "rails_helper"

describe BrowserSession::PayloadType do
  subject(:type) { described_class.new }

  def round_trip(value)
    type.deserialize(type.serialize(value))
  end

  it "keeps symbols, dates and times used in real sessions" do
    time = Time.utc(2026, 1, 2, 3, 4, 5)
    zoned = Time.find_zone!("London").local(2026, 7, 1, 12)
    payload = {
      "recurrences" => { recurrences: [Date.new(2026, 1, 1)], confirmed_recurrences: [] },
      "gitis_contact" => { candidate_id: "abc", dbs_certificate_issued_at: time, nested: { 1 => :a } },
      "uuid_map" => { "uuid" => 123 },
      "state" => "text",
      "zoned" => zoned
    }

    result = round_trip(payload)

    expect(result).to eq payload
    expect(result["zoned"]).to be_a ActiveSupport::TimeWithZone
    expect(result["zoned"].time_zone.name).to eq "London"
    expect(result["recurrences"][:recurrences].first).to be_a Date
  end

  it "keeps a DfE Sign-in userinfo object" do
    userinfo = OpenIDConnect::ResponseObject::UserInfo.new(sub: "abc", given_name: "A")

    result = round_trip("current_user" => userinfo)["current_user"]

    expect(result).to be_a OpenIDConnect::ResponseObject::UserInfo
    expect(result.raw_attributes).to eq(sub: "abc", given_name: "A")
    expect(result.sub).to eq "abc"
  end

  it "does not confuse a user hash that uses the tag key" do
    expect(round_trip("x" => { "_t" => "symbol", "v" => "a" })).to eq("x" => { "_t" => "symbol", "v" => "a" })
  end

  it "refuses values outside the allow-list" do
    expect { type.serialize("x" => Object.new) }.to raise_error(described_class::UnsupportedValue)
    expect { type.serialize("x" => DateTime.now) }.to raise_error(described_class::UnsupportedValue)
  end

  it "never instantiates classes named by stored data" do
    stored = { "x" => { "_t" => "Kernel" } }.to_json

    expect { type.deserialize(stored) }.to raise_error(described_class::UnsupportedValue)
  end
end
