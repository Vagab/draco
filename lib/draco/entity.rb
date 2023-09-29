module Draco
  # Public: A general purpose game object that consists of a unique id and a collection of Components.
  class Entity
    # rubocop:disable Style/ClassVars
    @default_components = {}
    @@next_id = 1

    # Internal: Resets the default components for each class that inherites Entity.
    #
    # sub - The class that is inheriting Entity.
    #
    # Returns nothing.
    def self.inherited(sub)
      super
      sub.instance_variable_set(:@default_components, {})
    end

    # Public: Adds a default component to the Entity.
    #
    # component - The class of the Component to add by default.
    # defaults - The Hash of default values for the Component data. (default: {})
    #
    # Examples
    #
    #   component(Visible)
    #
    #   component(Position, x: 0, y: 0)
    #
    # Returns nothing.
    def self.component(component, defaults = {})
      @default_components[component] = defaults
    end

    # Public: Creates a tag Component. If the tag already exists, return it.
    #
    # name - The string or symbol name of the component.
    #
    # Returns a class with subclass Draco::Component.
    def self.Tag(name) # rubocop:disable Naming/MethodName
      Draco::Tag(name)
    end

    class << self
      # Internal: Returns the default components for the class.
      attr_reader :default_components
    end

    # Public: Returns the Integer id of the Entity.
    attr_reader :id

    # Public: Returns the Array of the Entity's components
    attr_reader :components

    # Public: Initialize a new Entity.
    #
    # args - A Hash of arguments to pass into the components.
    #
    # Examples
    #
    #   class Player < Draco::Entity
    #     component Position, x: 0, y: 0
    #   end
    #
    #   Player.new(position: {x: 100, y: 100})
    def initialize(args = {})
      @id = args.fetch(:id, @@next_id)
      @@next_id = [@id + 1, @@next_id].max
      @subscriptions = []

      setup_components(args)
      after_initialize
    end

    # Internal: Sets up the default components for the class.
    #
    # args - A hash of arguments to pass into the generated components.
    #
    # Returns nothing.
    def setup_components(args)
      @components = ComponentStore.new(self)

      self.class.default_components.each do |component, default_args|
        arguments = default_args.merge(args[Draco.underscore(component.name.to_s).to_sym] || {})
        @components << component.new(arguments)
      end
    end

    # Public: Callback run after the entity is initialized.
    #
    # This is empty by default but is present to allow plugins to tie into.
    #
    # Returns nothing.
    def after_initialize; end

    # Public: Subscribe to an Entity's Component updates.
    #
    # subscriber - The object to notify when Components change.
    #
    # Returns nothing.
    def subscribe(subscriber)
      @subscriptions << subscriber
    end

    # Public: Callback run before a component is added.
    #
    # component - The component that will be added.
    #
    # Returns the component to add.
    def before_component_added(component)
      component
    end

    # Public: Callback run after a component is added.
    #
    # component - The component that was added.
    #
    # Returns the added component.
    def after_component_added(component)
      @subscriptions.each { |sub| sub.component_added(self, component) }
      component
    end

    # Public: Callback run before a component is deleted.
    #
    # component - The component that will be removed.
    #
    # Returns the component to remove.
    def before_component_removed(component)
      component
    end

    # Public: Callback run after a component is deleted.
    #
    # component - The component that was removed.
    #
    # Returns the removed component.
    def after_component_removed(component)
      @subscriptions.each { |sub| sub.component_removed(self, component) }
      component
    end

    # Public: Serializes the Entity to save the current state.
    #
    # Returns a Hash representing the Entity.
    def serialize
      serialized = { class: self.class.name.to_s, id: id }

      components.each do |component|
        serialized[Draco.underscore(component.class.name.to_s).to_sym] = component.serialize
      end

      serialized
    end

    # Public: Returns a String representation of the Entity.
    def inspect
      serialize.to_s
    end

    # Public: Returns a String representation of the Entity.
    def to_s
      serialize.to_s
    end

    # Signature
    #
    # <underscored_component_name>
    #
    # underscored_component_name - The component to access the data from
    #
    # Public: Get the component associated with this Entity.
    # This method will be available for each component.
    #
    # Examples
    #
    #   class Creature < Draco::Entity
    #     component CreatureStats, strength: 10
    #   end
    #
    #   creature = Creature.new
    #   creature.creature_stats
    #
    # Returns the Component instance.

    def method_missing(method, *args, &block)
      component = components[method.to_sym]
      return component if component

      super
    end

    def respond_to_missing?(method, _include_private = false)
      !!components[method.to_sym] or super
    end
  end
end
