class NotifyEmail::CandidateRequestConfirmationNoPii < Notify
  attr_accessor \
    :candidate_dbs_check_document,
    :candidate_degree_stage,
    :candidate_degree_subject,
    :candidate_teaching_stage,
    :candidate_teaching_subject_first_choice,
    :candidate_teaching_subject_second_choice,
    :placement_outcome,
    :placement_availability,
    :school_name,
    :cancellation_url

  def initialize(
    to:,
    candidate_dbs_check_document:,
    candidate_degree_stage:,
    candidate_degree_subject:,
    candidate_teaching_stage:,
    candidate_teaching_subject_first_choice:,
    candidate_teaching_subject_second_choice:,
    placement_outcome:,
    placement_availability:,
    school_name:,
    cancellation_url:
  )

    self.candidate_dbs_check_document             =        candidate_dbs_check_document
    self.candidate_degree_stage                   =        candidate_degree_stage
    self.candidate_degree_subject                 =        candidate_degree_subject
    self.candidate_teaching_stage                 =        candidate_teaching_stage
    self.candidate_teaching_subject_first_choice  =        candidate_teaching_subject_first_choice
    self.candidate_teaching_subject_second_choice =        candidate_teaching_subject_second_choice
    self.placement_outcome                        =        placement_outcome
    self.placement_availability                   =        placement_availability
    self.school_name                              =        school_name
    self.cancellation_url                         =        cancellation_url

    super(to: to)
  end

  def self.from_application_preview(to, application_preview, cancellation_url)
    new \
      to: to,
      candidate_dbs_check_document: application_preview.dbs_check_document,
      candidate_degree_stage: application_preview.degree_stage,
      candidate_degree_subject: application_preview.degree_subject,
      candidate_teaching_stage: application_preview.teaching_stage,
      candidate_teaching_subject_first_choice: application_preview.teaching_subject_first_choice,
      candidate_teaching_subject_second_choice: application_preview.teaching_subject_second_choice,
      placement_outcome: application_preview.placement_outcome,
      placement_availability: application_preview.placement_availability_description,
      school_name: application_preview.school.name,
      cancellation_url: cancellation_url
  end

private

  def template_id
    '8ee470a1-0b94-48ee-9fe7-98b7beb8921c'
  end

  def personalisation
    {
      candidate_dbs_check_document: candidate_dbs_check_document,
      candidate_degree_stage: candidate_degree_stage,
      candidate_degree_subject: candidate_degree_subject,
      candidate_teaching_stage: candidate_teaching_stage,
      candidate_teaching_subject_first_choice: candidate_teaching_subject_first_choice,
      candidate_teaching_subject_second_choice: candidate_teaching_subject_second_choice,
      placement_outcome: placement_outcome,
      placement_availability: placement_availability,
      school_name: school_name,
      cancellation_url: cancellation_url
    }
  end
end
