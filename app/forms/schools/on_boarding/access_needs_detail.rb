module Schools
  module OnBoarding
    class AccessNeedsDetail < Step
      DEFAULT_COPY = <<~TEXT.freeze
        We offer facilities and provide an inclusive environment for students,
        staff and school experience candidates with disability and access needs.

        We're happy to discuss your disability or access needs before or as part
        of your school experience request.
      TEXT

      attribute :description, :string

      validates :description, presence: true

      def self.compose(description)
        new description: description
      end

      def add_default_copy!
        self.description = DEFAULT_COPY
      end
    end
  end
end
