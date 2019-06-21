module Bookings::Gitis
  class IdChangedUnexpectedly < RuntimeError; end

  module Entity
    extend ActiveSupport::Concern
    ID_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/.freeze

    included do
      include ActiveModel::Model

      class_attribute :entity_path
      self.entity_path = derive_entity_path

      class_attribute :primary_key
      self.primary_key = derive_primary_key
    end

    def initialize
      raise "Abstract Class - implement initialize in entity model"
    end

    def attributes
      @attributes ||= {}
    end

    def reset
      @attributes = @dirty_attributes = nil
    end

    def changed_attributes
      attributes.slice(*dirty_attributes)
    end

    def reset_dirty_attributes
      @dirty_attributes = nil
    end

    def dirty_attributes
      @dirty_attributes ||= Set.new
    end

    def entity_id=(e_id)
      normalised_id = e_id.to_s.downcase
      id_match = normalised_id.match(/\A#{entity_path}\(([a-z0-9-]{36})\)\z/)
      if id_match && id_match[1]
        self.id = id_match[1]
      else
        raise InvalidEntityIdError
      end
    end

    def entity_id
      id ? "#{entity_path}(#{id})" : entity_path
    end

    class InvalidEntityIdError < RuntimeError; end

    module ClassMethods
    protected

      def entity_id_attribute(attr_name)
        define_method :"#{attr_name}" do
          attributes[attr_name.to_s]
        end

        define_method :id do
          attributes[attr_name.to_s]
        end

        define_method :"#{attr_name}=" do |assigned_id|
          if attributes[attr_name.to_s].blank?
            attributes[attr_name.to_s] = assigned_id
          elsif attributes[attr_name.to_s].to_s != assigned_id.to_s
            fail IdChangedUnexpectedly
          end
        end

        define_method :id= do |value|
          self.send(:"#{attr_name}=", value)
        end
      end

      def entity_attribute(attr_name)
        define_method :"#{attr_name}" do
          attributes[attr_name.to_s]
        end

        define_method :"#{attr_name}=" do |value|
          unless value == send(attr_name.to_sym)
            dirty_attributes << attr_name.to_s
          end

          attributes[attr_name.to_s] = value
        end
      end

      def entity_attributes(*attr_names)
        Array.wrap(attr_names).flatten.each do |attr_name|
          entity_attribute(attr_name)
        end
      end

      def derive_entity_path
        model_name.to_s.underscore.split('/').last.pluralize
      end

      def derive_primary_key
        model_name.to_s.underscore.split('/').last + 'id'
      end
    end
  end
end
