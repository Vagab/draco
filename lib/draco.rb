# frozen_string_literal: true
#
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup # ready!
# Public: Draco is an Entity Component System for use in game engines like DragonRuby.
#
# An Entity Component System is an architectural pattern used in game development to decouple behavior from objects.
module Draco
  # Public: The data to associate with an Entity.

  # Public: Creates a new empty component at runtime. If the given Class already exists, it reuses the existing Class.
  #
  # name - The symbol or string name of the component. It can be either camelcase or underscored.
  #
  # Returns a Class with superclass of Draco::Component.
  def self.Tag(name) # rubocop:disable Naming/MethodName
    klass_name = camelize(name)

    return Object.const_get(klass_name) if Object.const_defined?(klass_name)

    klass = Class.new(Component)
    Object.const_set(klass_name, klass)
  end

  # Internal: Converts a camel cased string to an underscored string.
  #
  # Examples
  #
  #   underscore("CamelCase")
  #   # => "camel_case"
  #
  # Returns a String.
  def self.underscore(string)
    string.to_s.split("::").last.bytes.map.with_index do |byte, i|
      if byte > 64 && byte < 97
        downcased = byte + 32
        i.zero? ? downcased.chr : "_#{downcased.chr}"
      else
        byte.chr
      end
    end.join
  end

  # Internal: Converts an underscored string into a camel case string.
  #
  # Examples
  #
  #   camlize("camel_case")
  #   # => "CamelCase"
  #
  # Returns a string.
  def self.camelize(string) # rubocop:disable Metrics/MethodLength
    modifier = -32

    string.to_s.bytes.map do |byte|
      if byte == 95
        modifier = -32
        nil
      else
        char = (byte + modifier).chr
        modifier = 0
        char
      end
    end.compact.join
  end
end

loader.eager_load
