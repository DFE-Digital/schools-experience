class Candidates::SchoolStub
  def self.find(identifier)
    new Candidates::School.find(identifier)
  end

  def initialize(school)
    @school = school
    @fallback = YAML.load_file('demo-school.yml')
  end

  def respond_to_missing?(method, _include_private = false)
    @school.respond_to?(method, false) || @fallback.key?(method.to_s)
  end

  def method_missing(method, *args, &block)
    if @school.respond_to?(method, false)
      @school.public_send(method, *args, &block)
    elsif @fallback.key?(method.to_s)
      @fallback[method.to_s]
    else
      super
    end
  end

  # not sure why this isn't cascading through needed but this fixes it
  def to_param
    @school.to_param
  end
end
