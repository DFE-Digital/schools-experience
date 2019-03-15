require File.join(Rails.root, "lib", "data", "school_importer")
require File.join(Rails.root, "lib", "data", "school_enhancer")

HEADER_MAPPING = {
  :timestamp => "Timestamp",
  :exclude_from_phase_one => "Do you want to be excluded from Phase 1 of the new service commencing on 1st April",
  :exclude_from_phase_one_reason => "Please could you let the team know why so we can improve the service in future",
  :urn => "Enter your school's URN",
  :contact_email => "Please enter the email address you would like to use for the new service (from 1st April)",
  :coordinator => "Do you arrange school experience placements at more than one school?",
  :coordinated_schools => "Please give the name and URNs of the school you manage school experience for.  URNs can be found via https://get-information-schools.service.gov.uk/",
  :secondary_subjects => "Secondary school experience subjects",
  :teaching_school => "Is this a teaching school?",
  :available_at_easter => "Will your school experience administrator be available to review school experience requests at any point over the Easter holiday period?",
  :empty_1 => "empty_1",
  :school_experience_description => "Enter your school experience description (max. 150 words)",
  :empty_2 => "empty_2",
  :empty_3 => "empty_3",
  :primary_key_stage_details => "Primary key stages",
  :teacher_training_details => "If yes, please provide details",
  :website => "Enter a web address (optional)",
  :school_experience_availability_details => "Enter your school experience availability details",
  :empty_4 => "empty_4",
  :provide_teacher_training => "Do you run your own teacher training or have any links to teacher training organisations and providers?",
  :provide_teacher_training_response => "If there are",
  :provide_teacher_training_response_row_2 => "Please detail your school information below [Row 2]",
  :provide_teacher_training_response_row_3 => "Please detail your school information below [Row 3]",
  :provide_teacher_training_response_row_4 => "Please detail your school information below [Row 4]",
  :empty_5 => "empty_5",
  :important_information => "Please use the below section to include any important information you would like to make the team aware of. ",
  :dress_code => "what is the dress code for school experience candidates?",
  :free_parking => "Does the school provide free parking?",
  :start_and_finish_times => "What are the placement start and finish times?",
  :itt_offere => "Does your school offer Initial Teacher Training (ITT) courses? (If so feel free to add a short description / link to a site)"
}.freeze

namespace :data do
  namespace :schools do
    # The URNs should be provided in a CSV with the following two headings:
    # urn, contact_email
    #
    # The GiaS data is a dump taken from the Get Information About Schools
    # downloads page
    #
    # https://get-information-schools.service.gov.uk/Downloads
    desc "Import GiaS (EduBase) data based on a list of URNs"
    task :import, %i{tpuk edubase} => :environment do |_t, args|
      tpuk_data = CSV.parse(
        File.read(args[:tpuk]).scrub,
        headers: true
      )

      edubase_data = CSV.parse(
        File.read(args[:edubase]).scrub,
        headers: true
      )

      SchoolImporter.new(tpuk_data, edubase_data).import
    end

    desc "Enhance school data using information captured in the questionnaire"
    task :enhance, %i{questionnaire} => :environment do |_t, args|
      # read the file using the headers defined above
      # drop the header line as we're using our own shorter ones
      response_data = CSV.parse(
        File.read(args[:questionnaire]).scrub,
        headers: HEADER_MAPPING.keys
      ).drop(1)

      SchoolEnhancer.new(response_data).enhance
    end
  end
end
