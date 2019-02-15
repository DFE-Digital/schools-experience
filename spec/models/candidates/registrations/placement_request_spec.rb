require 'rails_helper'

describe Candidates::Registrations::PlacementRequest, type: :model do
  it { is_expected.to have_db_column(:date_start).of_type :date }
  it { is_expected.to have_db_column(:date_end).of_type :date }
  it { is_expected.to have_db_column(:objectives).of_type :text }
  it { is_expected.to have_db_column(:access_needs).of_type :boolean }
  it { is_expected.to have_db_column(:access_needs_details).of_type :text }
  it { is_expected.to have_db_column(:urn).of_type :string }
  it { is_expected.to have_db_column(:degree_stage).of_type :string }
  it { is_expected.to have_db_column(:degree_stage_explanination).of_type :text }
  it { is_expected.to have_db_column(:degree_subject).of_type :string }
  it { is_expected.to have_db_column(:teaching_stage).of_type :string }
  it { is_expected.to have_db_column(:subject_first_choice).of_type :string }
  it { is_expected.to have_db_column(:subject_second_choice).of_type :string }
  it { is_expected.to have_db_column(:has_dbs_check).of_type :boolean }
end
