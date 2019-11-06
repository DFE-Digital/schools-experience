module Bookings::Gitis
  class IdChangedUnexpectedly < RuntimeError; end

  module Entity
    extend ActiveSupport::Concern
    include ActiveModel::Validations
    include ActiveModel::Conversion

    ID_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/.freeze
    def self.valid_id?(id)
      ID_FORMAT.match? id.to_s
    end

    included do
      extend ActiveModel::Naming
      extend ActiveModel::Translation

      delegate :attributes_to_select, to: :class

      class_attribute :entity_path
      self.entity_path = derive_entity_path

      class_attribute :primary_key
      self.primary_key = derive_primary_key

      class_attribute :select_attribute_names
      self.select_attribute_names = Set.new

      class_attribute :association_attribute_names
      self.association_attribute_names = Set.new

      class_attribute :create_blacklist
      self.create_blacklist = []

      class_attribute :update_blacklist
      self.update_blacklist = []
    end

    def initialize(attrs = {})
      populate attrs

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

    def cache_key
      "#{entity_path}/#{id}"
    end

    class InvalidEntityIdError < RuntimeError; end

  private

    def populate(attrs)
      attrs.stringify_keys.each do |attr_name, value|
        if self.class.primary_key == attr_name ||
            (respond_to?(:"#{attr_name}=") &&
            self.class.all_attribute_names.include?(attr_name))

          send(:"#{attr_name}=", value)
        end
      end
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

        unless except.include?(:select) || except.include?(:read)
          self.select_attribute_names << attr_name.to_s
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

      def derive_primary_key
        model_name.to_s.downcase.split('::').last + 'id'
      end

      def entity_association(attr_name, entity_type)
        self.association_attribute_names << attr_name.to_s
        entity_attribute :"#{attr_name}@odata.bind", except: :select

        value_name = "_#{attr_name.downcase}_value"
        self.select_attribute_names << value_name

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
            raise InvalidEntityIdError
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
        self.association_attribute_names << attr_name.to_s

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
