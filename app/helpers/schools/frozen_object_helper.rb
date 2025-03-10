module Schools
  module FrozenObjectHelper
    def duplicate_if_frozen(obj)
      obj.frozen? ? obj.dup : obj
    end
  end
end
