require 'rails_helper'

describe Schools::OnBoarding::CurrentStep do
  let! :secondary_phase do
    FactoryBot.create :bookings_phase, :secondary
  end

  let! :college_phase do
    FactoryBot.create :bookings_phase, :college
  end

  context '.for' do
    let :returned_step do
      described_class.for school_profile
    end

    context 'candidate_requirement required' do
      let :school_profile do
        FactoryBot.build_stubbed :school_profile
      end

      it 'returns :candidate_requirement' do
        expect(returned_step).to eq :candidate_requirement
      end
    end

    context 'candidate_requirement not required' do
      context 'fees required' do
        let :school_profile do
          FactoryBot.build_stubbed :school_profile, :with_candidate_requirement
        end

        it 'returns :fees' do
          expect(returned_step).to eq :fees
        end
      end

      context 'fees not required' do
        context 'administration_fee required' do
          let :school_profile do
            FactoryBot.build_stubbed :school_profile,
              :with_candidate_requirement,
              fees_administration_fees: true,
              fees_dbs_fees: false,
              fees_other_fees: false
          end

          it 'returns :administration_fee' do
            expect(returned_step).to eq :administration_fee
          end
        end

        context 'administration_fee not required' do
          context 'dbs_fee required' do
            let :school_profile do
              FactoryBot.build_stubbed :school_profile,
                :with_candidate_requirement,
                fees_administration_fees: false,
                fees_dbs_fees: true,
                fees_other_fees: false
            end

            it 'returns :dbs_fee' do
              expect(returned_step).to eq :dbs_fee
            end
          end

          context 'dbs_fee not required' do
            context 'other_fees required' do
              let :school_profile do
                FactoryBot.build_stubbed :school_profile,
                  :with_candidate_requirement,
                  fees_administration_fees: false,
                  fees_dbs_fees: false,
                  fees_other_fees: true
              end

              it 'returns :other_fees' do
                expect(returned_step).to eq :other_fee
              end
            end

            context 'other_fees not required' do
              context 'phases_list required' do
                let :school_profile do
                  FactoryBot.build_stubbed :school_profile,
                    :with_candidate_requirement,
                    fees_administration_fees: false,
                    fees_dbs_fees: false,
                    fees_other_fees: false
                end

                it 'returns :phases_list' do
                  expect(returned_step).to eq :phases_list
                end
              end

              context 'phases_list not required' do
                context 'key_stage_list required' do
                  let :school_profile do
                    FactoryBot.build_stubbed :school_profile,
                      :with_candidate_requirement,
                      :with_fees,
                      :with_administration_fee,
                      :with_dbs_fee,
                      :with_other_fee,
                      :with_phases
                  end

                  it 'returns :key_stage_list' do
                    expect(returned_step).to eq :key_stage_list
                  end
                end

                context 'key_stage_list not required' do
                  context 'secondary_subjects required' do
                    let :school_profile do
                      FactoryBot.build_stubbed :school_profile,
                        :with_candidate_requirement,
                        :with_fees,
                        :with_administration_fee,
                        :with_dbs_fee,
                        :with_other_fee,
                        :with_phases,
                        :with_key_stage_list
                    end

                    it 'returns secondary_subjects' do
                      expect(returned_step).to eq :secondary_subjects
                    end
                  end

                  context 'secondary_subjects not required' do
                    context 'college_subjects required' do
                      let :school_profile do
                        FactoryBot.create :school_profile,
                          :with_candidate_requirement,
                          :with_fees,
                          :with_administration_fee,
                          :with_dbs_fee,
                          :with_other_fee,
                          :with_phases,
                          :with_key_stage_list,
                          :with_secondary_subjects
                      end

                      it 'returns college_subjects' do
                        expect(returned_step).to eq :college_subjects
                      end
                    end

                    context 'college_subjects not required' do
                      context 'specialism required' do
                        let :school_profile do
                          FactoryBot.create :school_profile,
                            :with_candidate_requirement,
                            :with_fees,
                            :with_administration_fee,
                            :with_dbs_fee,
                            :with_other_fee,
                            :with_phases,
                            :with_key_stage_list,
                            :with_secondary_subjects,
                            :with_college_subjects
                        end

                        it 'returns :specialism' do
                          expect(returned_step).to eq :specialism
                        end
                      end

                      context 'specialism not required' do
                        context 'candidate_experience_detail required' do
                          let :school_profile do
                            FactoryBot.create :school_profile,
                              :with_candidate_requirement,
                              :with_fees,
                              :with_administration_fee,
                              :with_dbs_fee,
                              :with_other_fee,
                              :with_phases,
                              :with_key_stage_list,
                              :with_secondary_subjects,
                              :with_college_subjects,
                              :with_specialism
                          end

                          it 'returns :candidate_experience_detail' do
                            expect(returned_step).to \
                              eq :candidate_experience_detail
                          end
                        end

                        context 'candidate_experience_detail not required' do
                          xcontext 'availability required' do
                          end

                          context 'availability not required' do
                            context 'experience_outline requred' do
                              let :school_profile do
                                FactoryBot.create :school_profile,
                                  :with_candidate_requirement,
                                  :with_fees,
                                  :with_administration_fee,
                                  :with_dbs_fee,
                                  :with_other_fee,
                                  :with_phases,
                                  :with_key_stage_list,
                                  :with_secondary_subjects,
                                  :with_college_subjects,
                                  :with_specialism,
                                  :with_candidate_experience_detail
                              end

                              it 'returns :experience_outline' do
                                expect(returned_step).to \
                                  eq :experience_outline
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
