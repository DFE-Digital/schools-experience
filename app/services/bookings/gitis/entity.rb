module Bookings::Gitis
  class IdChangedUnexpectedly < RuntimeError; end

  module Entity
    extend ActiveSupport::Concern
    include ActiveModel::Validations
    include ActiveModel::Conversion

    ID_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/.freeze

    included do
      extend ActiveModel::Naming
      extend ActiveModel::Translation

      class_attribute :entity_path
      self.entity_path = derive_entity_path

      class_attribute :primary_key
      self.primary_key = derive_primary_key

      class_attribute :entity_attribute_names
      self.entity_attribute_names = Set.new

      class_attribute :create_blacklist
      self.create_blacklist = []

      class_attribute :update_blacklist
      self.update_blacklist = []
    end

    def initialize(*_args)
      reset_dirty_attributes if persisted?
    end

    def persisted?
      id.present?
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

    def attributes_for_update
      attributes.slice(*(changed_attributes.keys - update_blacklist))
    end

    def attributes_for_create
      keys = attributes.keys - ['id', primary_key] - create_blacklist
      keys.reject! { |k| attributes[k].nil? }

      attributes.slice(*keys)
    end

    def attributes
      @attributes ||= {}
    end

    def id
      attributes[primary_key]
    end

    def id=(value)
      attributes[primary_key] = value
    end

    def ==(other)
      return false unless other.is_a? self.class

      other.id == self.id
    end

    class InvalidEntityIdError < RuntimeError; end

    module ClassMethods
    protected

      def entity_id_attribute(attr_name)
        self.primary_key = attr_name.to_s

        define_method :"#{attr_name}" do
          attributes[attr_name.to_s]
        end

        define_method :"#{attr_name}=" do |assigned_id|
          if attributes[attr_name.to_s].blank?
            attributes[attr_name.to_s] = assigned_id
          elsif attributes[attr_name.to_s].to_s != assigned_id.to_s
            fail IdChangedUnexpectedly
          end
        end
      end

      def entity_attribute(attr_name, internal: false, except: nil)
        except = Array.wrap(except).map(&:to_sym)

        define_method :"#{attr_name}" do
          attributes[attr_name.to_s]
        end
        private :"#{attr_name}" if internal
        self.create_blacklist << attr_name.to_s if except.include?(:create)

        define_method :"#{attr_name}=" do |value|
          unless value == send(attr_name.to_sym)
            dirty_attributes << attr_name.to_s
          end

          attributes[attr_name.to_s] = value
        end
        private :"#{attr_name}=" if internal
        self.update_blacklist << attr_name.to_s if except.include?(:update)

        self.entity_attribute_names << attr_name.to_s
      end

      def entity_attributes(*attr_names, internal: false, except: nil)
        Array.wrap(attr_names).flatten.each do |attr_name|
          entity_attribute(attr_name, internal: internal, except: except)
        end
      end

      def derive_entity_path
        model_name.to_s.downcase.split('::').last.pluralize
      end

      def derive_primary_key
        model_name.to_s.downcase.split('::').last + 'id'
      end

      def entity_association(attr_name, entity_type)
        entity_attribute :"#{attr_name}@odata.bind"

        define_method :"_#{attr_name}_value" do
          send(:"#{attr_name}@odata.bind")&.gsub(/\A[^(]+\(([^)]+)\).*\z/, '\1')
        end

        define_method :"_#{attr_name}_value=" do |id_value|
          if id_value.nil?
            send :"#{attr_name}@odata.bind=", nil
          elsif ID_FORMAT.match?(id_value)
            send :"#{attr_name}@odata.bind=", "#{entity_type.entity_path}(#{id_value})"
          else
            raise InvalidEntityIdError
          end
        end

        define_method :"#{attr_name}=" do |entity_or_value|
          if entity_or_value.is_a? Bookings::Gitis::Entity
            send :"#{attr_name}@odata.bind=", entity_or_value.entity_id
          else
            send :"_#{attr_name}_value=", entity_or_value
          end
        end
      end
    end
  end
end
