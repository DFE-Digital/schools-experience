module YamlModel
  extend ActiveSupport::Concern
  include ActiveModel::Model
  include ActiveModel::Attributes

  def ==(other)
    other.respond_to?(:attributes) && other.attributes == self.attributes
  end

  module ClassMethods
    def primary_key
      @_primary_key || raise(NotImplementedError)
    end

    def pk_attribute(attribute_name, *args, **kwargs)
      raise("Primary Key already assigned") if @_primary_key

      @_primary_key = attribute_name.to_sym
      attribute(attribute_name, *args, **kwargs)
    end

    def find(key)
      new load_yaml(key).merge(primary_key => key)
    end

    def keys
      files.map { |f| File.basename(f, '.yml') }.sort
    end

    def all
      keys.map(&method(:find))
    end

  private

    def load_yaml(key)
      YAML.load_file instance_file key
    end

    def instance_file(key)
      data_path.join "#{key}.yml"
    end

    def data_path
      Rails.root.join('data', model_name.collection).freeze
    end

    def files
      Dir[data_path.join('*.yml')]
    end
  end
end
