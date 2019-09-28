module Bookings::Gitis
  class IdChangedUnexpectedly < RuntimeError; end
  class MissingPrimaryKey < RuntimeError; end
  class InvalidEntityId < RuntimeError; end

  module Entity
    extend ActiveSupport::Concern

    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Dirty

    ID_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/.freeze

    included do
      delegate :attributes_to_select, to: :class


      class_attribute :entity_path
      self.entity_path = derive_entity_path

      class_attribute :primary_key

      class_attribute :select_attribute_names
      self.select_attribute_names = Set.new.freeze

      class_attribute :association_attribute_names
      self.association_attribute_names = Set.new.freeze

      class_attribute :create_blacklist
      self.create_blacklist = [].freeze

      class_attribute :update_blacklist
      self.update_blacklist = [].freeze
    end

    def initialize(attrs = {})
      @init_data = attrs.stringify_keys

      super

      clear_changes_information if persisted?
    end

    def persisted?
      self.class.primary_key && id.present?
    end

    def reset
      restore_attributes
    end

    def entity_id=(e_id)
      normalised_id = e_id.to_s.downcase
      id_match = normalised_id.match(/\A#{entity_path}\(([a-z0-9-]{36})\)\z/)

      if id_match && id_match[1]
        self.id = id_match[1]
      else
        fail InvalidEntityId
      end
    end

    def entity_id
      id ? "#{entity_path}(#{id})" : entity_path
    end

    def attributes_for_update
      attributes.slice(*(changed - update_blacklist))
    end

    def attributes_for_create
      attributes.except(*create_blacklist).reject { |_k, v| v.nil? }
    end

    def ==(other)
      return false unless other.is_a? self.class

      other.id == self.id
    end

    # Will get overwritten if entity_id_attribute is defined
    def id
      fail MissingPrimaryKey
    end
    alias_method :id=, :id

  private

    def sanitize_for_mass_assignment(*args)
      # Modified to allow for unexpected attrs being returned from Dynamics
      super.select { |k, _v| respond_to?(:"#{k}=") }
    end

    def write_primary_key(value)
      if value.blank?
        return
      elsif !value.to_s.match?(ID_FORMAT)
        fail InvalidEntityId
      elsif id.present? && id != value
        fail IdChangedUnexpectedly
      end

      write_attribute self.class.primary_key, value
    end

    module ClassMethods
      def attributes_to_select
        self.select_attribute_names.to_a.join(',')
      end

      def all_attribute_names
        select_attribute_names + association_attribute_names
      end

    protected

      def entity_id_attribute(attr_name)
        self.primary_key = attr_name.to_s

        entity_attribute :"#{attr_name}", except: %i{create update}
        alias_attribute :id, :"#{attr_name}"

        define_method :"#{attr_name}=" do |value|
          write_primary_key(value)
        end
      end

      def entity_attribute(attr_name, internal: false, except: nil)
        except = Array.wrap(except).map(&:to_sym)

        attribute :"#{attr_name}"

        private :"#{attr_name}" if internal
        private :"#{attr_name}=" if internal

        if except.include?(:create)
          self.create_blacklist = create_blacklist + [attr_name.to_s]
        end

        if except.include?(:update)
          self.update_blacklist = update_blacklist + [attr_name.to_s]
        end

        unless except.include?(:select) || except.include?(:read)
          self.select_attribute_names = select_attribute_names + [attr_name.to_s]
        end
      end

      def entity_attributes(*attr_names, internal: false, except: nil)
        Array.wrap(attr_names).flatten.each do |attr_name|
          entity_attribute(attr_name, internal: internal, except: except)
        end
      end

      def derive_entity_path
        model_name.to_s.downcase.split('::').last.pluralize
      end

      def entity_association(attr_name, entity_type)
        self.association_attribute_names = association_attribute_names + [attr_name.to_s]
        entity_attribute :"#{attr_name}@odata.bind", except: :select

        value_name = "_#{attr_name.downcase}_value"
        self.select_attribute_names = select_attribute_names + [value_name]

        define_method :"#{value_name}" do
          send(:"#{attr_name}@odata.bind")&.gsub(/\A[^(]+\(([^)]+)\).*\z/, '\1')
        end

        # updating just the associated entities id
        define_method :"#{value_name}=" do |id_value|
          return if id_value == send(:"#{attr_name}@odata.bind")

          if send(attr_name)&.id != id_value
            instance_variable_set("@_#{attr_name}", nil)
          end

          if id_value.nil?
            send :"#{attr_name}@odata.bind=", nil
          elsif ID_FORMAT.match?(id_value)
            send :"#{attr_name}@odata.bind=", "#{entity_type.entity_path}(#{id_value})"
          else
            raise InvalidEntityId
          end
        end

        # assigning data or class to associated entity
        define_method :"#{attr_name}=" do |entity_or_value|
          case entity_or_value
          when Bookings::Gitis::Entity
            instance_variable_set "@_#{attr_name}", entity_or_value
            send :"#{attr_name}@odata.bind=", entity_or_value.entity_id
          when Hash
            entity = entity_type.new(entity_or_value)
            instance_variable_set "@_#{attr_name}", entity
            send :"#{attr_name}@odata.bind=", entity.entity_id
          else
            send :"#{value_name}=", entity_or_value
          end
        end

        define_method :"#{attr_name}" do
          instance_variable_get "@_#{attr_name}"
        end
      end

      def entity_collection(attr_name, entity_type)
        self.association_attribute_names = association_attribute_names + [attr_name.to_s]

        define_method :"#{attr_name}" do
          instance_variable_get("@_#{attr_name}")
        end

        define_method :"#{attr_name}=" do |entities|
          entities = Array.wrap(entities).map do |entity|
            case entity
            when Bookings::Gitis::Entity
              entity
            when Hash
              entity_type.new(entity)
            else
              raise "Invalid data type"
            end
          end

          instance_variable_set("@_#{attr_name}", entities)
        end
      end
    end
  end
end
