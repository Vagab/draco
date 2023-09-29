class Draco::Component
  @attribute_options = {}

  # Internal: Resets the attribute options for each class that inherits Component.
  #
  # sub - The class that is inheriting Entity.
  #
  # Returns nothing.
  def self.inherited(sub)
    super
    sub.instance_variable_set(:@attribute_options, {})
  end

  # Public: Defines an attribute for the Component.
  #
  # name - The Symbol name of the attribute.
  # options - The Hash options for the Component (default: {}):
  #           :default - The initial value for the attribute if one is not provided.
  #
  # Returns nothing.
  def self.attribute(name, options = {})
    attr_accessor name

    @attribute_options[name] = options
  end

  # Internal: Returns the Hash attribute options for the current Class.
  class << self
    attr_reader :attribute_options
  end

  # Public: Creates a tag Component. If the tag already exists, return it.
  #
  # name - The string or symbol name of the component.
  #
  # Returns a class with subclass Draco::Component.
  def self.Tag(name) # rubocop:disable Naming/MethodName
    Draco::Tag(name)
  end

  # Public: Initializes a new Component.
  #
  # values - The Hash of values to set for the Component instance (default: {}).
  #          Each key should be the Symbol name of the attribute.
  #
  # Examples
  #
  #   class Position < Draco::Component
  #     attribute :x, default: 0
  #     attribute :y, default: 0
  #   end
  #
  #   Position.new(x: 100, y: 100)
  def initialize(values = {})
    self.class.attribute_options.each do |name, options|
      value = values.fetch(name.to_sym, options[:default])
      instance_variable_set("@#{name}", value)
    end
    after_initialize
  end

  # Public: Callback run after the component is initialized.
  #
  # This is empty by default but is present to allow plugins to tie into.
  #
  # Returns nothing.
  def after_initialize; end

  # Public: Serializes the Component to save the current state.
  #
  # Returns a Hash representing the Component.
  def serialize
    attrs = { class: self.class.name.to_s }

    instance_variables.each do |attr|
      name = attr.to_s.gsub("@", "").to_sym
      attrs[name] = instance_variable_get(attr)
    end

    attrs
  end

  # Public: Returns a String representation of the Component.
  def inspect
    serialize.to_s
  end

  # Public: Returns a String representation of the Component.
  def to_s
    serialize.to_s
  end
end
