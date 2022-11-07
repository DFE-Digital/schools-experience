class User < ApplicationRecord
  rolify

  attribute :given_name, :string
  attribute :family_name, :string

  class << self
    def exchange(attributes)
      User.find_or_create_by(sub: attributes[:sub]) do |user|
        user.attributes = trim_unknown_attributes(attributes)
      end
    end

    def exchange_all(keyed_attributes)
      find_or_create_by_subs(keyed_attributes.keys).each do |user|
        user.attributes = trim_unknown_attributes(keyed_attributes[user.sub])
      end
    end

    def find_or_create_by_subs(subs)
      existing_subs = User.where(sub: subs).pluck(:sub)

      new_users = subs
        .excluding(existing_subs)
        .map { |sub| { sub: sub } }

      User.create(new_users)

      User.where(sub: subs)
    end

    def trim_unknown_attributes(attributes)
      attributes.slice(*User.attribute_names.map(&:to_sym))
    end
  end
end
