class User < ApplicationRecord
  attr_writer :dfe_sign_in_user

  delegate :given_name, :family_name, :raw_attributes, to: :@dfe_sign_in_user

  class << self
    def exchange(dfe_sign_in_user)
      User.find_or_create_by(sub: dfe_sign_in_user.sub).tap do |user|
        user.dfe_sign_in_user = dfe_sign_in_user
      end
    end
  end
end
