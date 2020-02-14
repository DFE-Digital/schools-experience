module YamlModel
  extend ActiveSupport::Concern
  include ActiveModel::Model
  include ActiveModel::Attributes

  def persisted?
    true
  end

  def id
    attributes[self.class.primary_key.to_s]
  end

  def ==(other)
    other.respond_to?(:attributes) && other.attributes == self.attributes
  end

  module ClassMethods
    def primary_key
      @_primary_key || raise(NotImplementedError)
    end

    def id_attribute(attribute_name, *args, **kwargs)
      raise("Primary Key already assigned") if @_primary_key

      @_primary_key = attribute_name.to_sym
      attribute(attribute_name, *args, **kwargs)
    end

    def find(id)
      new load_yaml(id).merge(primary_key => id)
    end

    def ids
      files.map { |f| File.basename(f, '.yml') }.sort
    end

    def all
      ids.map(&method(:find))
    end

  private

    def load_yaml(id)
      YAML.load_file instance_file id
    end

    def instance_file(id)
      data_path.join "#{id}.yml"
    end

    def data_path
      Rails.root.join('data', model_name.collection).freeze
    end

    def files
      Dir[data_path.join('*.yml')]
    end
  end
end
