class NotifyEmail::SchoolRequestConfirmationWithPlacementRequestUrl < Notify
  attr_accessor :candidate_address,
    :candidate_dbs_check_document,
    :candidate_degree_stage,
    :candidate_degree_subject,
    :candidate_email_address,
    :candidate_name,
    :candidate_phone_number,
    :candidate_teaching_stage,
    :candidate_teaching_subject_first_choice,
    :candidate_teaching_subject_second_choice,
    :placement_outcome,
    :placement_availability,
    :placement_request_url,
    :school_name

  def initialize(
    to:,
    candidate_address:,
    candidate_dbs_check_document:,
    candidate_degree_stage:,
    candidate_degree_subject:,
    candidate_email_address:,
    candidate_name:,
    candidate_phone_number:,
    candidate_teaching_stage:,
    candidate_teaching_subject_first_choice:,
    candidate_teaching_subject_second_choice:,
    placement_outcome:,
    placement_availability:,
    placement_request_url:,
    school_name:
  )

    self.candidate_address                        =        candidate_address
    self.candidate_dbs_check_document             =        candidate_dbs_check_document
    self.candidate_degree_stage                   =        candidate_degree_stage
    self.candidate_degree_subject                 =        candidate_degree_subject
    self.candidate_email_address                  =        candidate_email_address
    self.candidate_name                           =        candidate_name
    self.candidate_phone_number                   =        candidate_phone_number
    self.candidate_teaching_stage                 =        candidate_teaching_stage
    self.candidate_teaching_subject_first_choice  =        candidate_teaching_subject_first_choice
    self.candidate_teaching_subject_second_choice =        candidate_teaching_subject_second_choice
    self.placement_outcome                        =        placement_outcome
    self.placement_availability                   =        placement_availability
    self.placement_request_url                    =        placement_request_url
    self.school_name                              =        school_name

    super(to: to)
  end

  def self.from_application_preview(to, application_preview, placement_request_url)
    new(
      to: to,
      candidate_address: application_preview.full_address,
      candidate_dbs_check_document: application_preview.dbs_check_document,
      candidate_degree_stage: application_preview.degree_stage,
      candidate_degree_subject: application_preview.degree_subject,
      candidate_email_address: application_preview.email_address,
      candidate_name: application_preview.full_name,
      candidate_phone_number: application_preview.telephone_number,
      candidate_teaching_stage: application_preview.teaching_stage,
      candidate_teaching_subject_first_choice: application_preview.teaching_subject_first_choice,
      candidate_teaching_subject_second_choice: application_preview.teaching_subject_second_choice,
      placement_outcome: application_preview.placement_outcome,
      placement_availability: application_preview.placement_availability_description,
      placement_request_url: placement_request_url,
      school_name: application_preview.school.name
    )
  end

private

  def template_id
    '74f5df05-548a-4949-8ec2-fcc27b9034d7'
  end

  def personalisation
    {
      candidate_address: candidate_address,
      candidate_dbs_check_document: candidate_dbs_check_document,
      candidate_degree_stage: candidate_degree_stage,
      candidate_degree_subject: candidate_degree_subject,
      candidate_email_address: candidate_email_address,
      candidate_name: candidate_name,
      candidate_phone_number: candidate_phone_number,
      candidate_teaching_stage: candidate_teaching_stage,
      candidate_teaching_subject_first_choice: candidate_teaching_subject_first_choice,
      candidate_teaching_subject_second_choice: candidate_teaching_subject_second_choice,
      placement_outcome: placement_outcome,
      placement_availability: placement_availability,
      placement_request_url: placement_request_url,
      school_name: school_name
    }
  end
end
