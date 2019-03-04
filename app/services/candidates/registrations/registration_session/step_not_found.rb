module Candidates
  module Registrations
    class RegistrationSession
      class StepNotFound < StandardError
        alias_method :key, :message

        def step_path
          model_path_name = key.split('_').insert(1, 'school').join('_')
          ['new', model_path_name, 'path'].join('_')
        end
      end
    end
  end
end
