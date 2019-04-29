module Schools
  module OnBoarding
    class Confirmation < Step
      attribute :acceptance, :boolean
      validates :acceptance, acceptance: true
    end
  end
end
