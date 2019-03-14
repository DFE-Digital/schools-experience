require File.join(Rails.root, "lib", "data", "school_importer")
require File.join(Rails.root, "lib", "data", "school_enhancer")

HEADER_MAPPING = {
  "Timestamp" => :timestamp,
  "Do you want to be excluded from Phase 1 of the new service commencing on 1st April" => :exclude_from_phase_one,
  "Please could you let the team know why so we can improve the service in future" => :exclude_from_phase_one_reason,
  "Enter your school's URN" => :urn,
  "Please enter the email address you would like to use for the new service (from 1st April)" => :contact_email,
  "Do you arrange school experience placements at more than one school?" => :coordinator,
  "Please give the name and URNs of the school you manage school experience for.  URNs can be found via https://get-information-schools.service.gov.uk/" => :coordinated_schools,
  "Secondary school experience subjects" => :secondary_subjects,
  "Is this a teaching school?" => :teaching_school,
  "Will your school experience administrator be available to review school experience requests at any point over the Easter holiday period?" => :available_at_easter,
  "empty_1" => :empty_1,
  "Enter your school experience description (max. 150 words)" => :school_experience_description,
  "empty_2" => :empty_2,
  "empty_3" => :empty_3,
  "Primary key stages" => :primary_key_stage_details,
  "If yes, please provide details" => :teacher_training_details,
  "Enter a web address (optional)" => :website,
  "Enter your school experience availability details" => :school_experience_availability_details,
  "empty_4" => :empty_4,
  "Do you run your own teacher training or have any links to teacher training organisations and providers?" => :provide_teacher_training,
  "If there are" => :provide_teacher_training_response,
  "Please detail your school information below [Row 2]" => :provide_teacher_training_response_row_2,
  "Please detail your school information below [Row 3]" => :provide_teacher_training_response_row_3,
  "Please detail your school information below [Row 4]" => :provide_teacher_training_response_row_4,
  "empty_5" => :empty_5,
  "Please use the below section to include any important information you would like to make the team aware of. " => :important_information,
  "what is the dress code for school experience candidates?" => :dress_code,
  "Does the school provide free parking?" => :free_parking,
  "What are the placement start and finish times?" => :start_and_finish_times,
  "Does your school offer Initial Teacher Training (ITT) courses? (If so feel free to add a short description / link to a site)" => :itt_offered
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
        headers: HEADER_MAPPING.values
      ).drop(1)

      SchoolEnhancer.new(response_data).enhance
    end
  end
end
