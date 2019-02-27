class NotifyEmail::SchoolRequestConfirmation < Notify
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
    :placement_finish_date,
    :placement_outcome,
    :placement_start_date,
    :school_name,
    :school_admin_name

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
    placement_finish_date:,
    placement_outcome:,
    placement_start_date:,
    school_name:,
    school_admin_name:
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
    self.placement_finish_date                    =        placement_finish_date
    self.placement_outcome                        =        placement_outcome
    self.placement_start_date                     =        placement_start_date
    self.school_name                              =        school_name
    self.school_admin_name                        =        school_admin_name

    super(to: to)
  end

  def self.from_application_preview(to, application_preview)
    NotifyEmail::SchoolRequestConfirmation.new(
      to: to,
      candidate_address: application_preview.full_address,
      candidate_dbs_check_document: application_preview.dbs_check_document, candidate_degree_stage: application_preview.degree_stage,
      candidate_degree_subject: application_preview.degree_subject,
      candidate_email_address: application_preview.email_address,
      candidate_name: application_preview.full_name,
      candidate_phone_number: application_preview.telephone_number,
      candidate_teaching_stage: application_preview.teaching_stage,
      candidate_teaching_subject_first_choice: application_preview.teaching_subject_first_choice,
      candidate_teaching_subject_second_choice: application_preview.teaching_subject_second_choice,
      placement_finish_date: application_preview.placement_date_end,
      placement_outcome: application_preview.placement_outcome,
      placement_start_date: application_preview.placement_date_start,
      school_name: application_preview.school,
      school_admin_name: "PLACEHOLDER FOR SCHOOL ADMIN"
    )
  end

private

  def template_id
    'dd4490f8-1d7b-455b-8502-47f57a65179a'
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
      placement_finish_date: placement_finish_date,
      placement_outcome: placement_outcome,
      placement_start_date: placement_start_date,
      school_name: school_name,
      school_admin_name: school_admin_name
    }
  end
end
