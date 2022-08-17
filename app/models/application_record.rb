class ApplicationRecord < ActiveRecord::Base
  include DfE::Analytics::Entities

  self.abstract_class = true
end
