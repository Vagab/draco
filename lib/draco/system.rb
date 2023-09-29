module Draco
  # Public: Systems contain the logic of the game.
  # The System runs on each tick and manipulates the Entities in the World.
  class System
    @filter = []

    # Public: Returns an Array of Entities that match the filter.
    attr_accessor :entities

    # Public: Returns the World this System is running in.
    attr_accessor :world

    # Public: Adds the given Components to the default filter of the System.
    #
    # Returns the current filter.
    def self.filter(*components)
      components.each do |component|
        @filter << component
      end

      @filter
    end

    # Internal: Resets the fuilter for each class that inherits System.
    #
    # sub - The class that is inheriting Entity.
    #
    # Returns nothing.
    def self.inherited(sub)
      super
      sub.instance_variable_set(:@filter, [])
    end

    # Public: Creates a tag Component. If the tag already exists, return it.
    #
    # name - The string or symbol name of the component.
    #
    # Returns a class with subclass Draco::Component.
    def self.Tag(name) # rubocop:disable Naming/MethodName
      Draco::Tag(name)
    end

    # Public: Initializes a new System.
    #
    # entities - The Entities to operate on (default: []).
    # world - The World running the System (default: nil).
    def initialize(entities: [], world: nil)
      @entities = entities
      @world = world
      after_initialize
    end

    # Public: Callback run after the system is initialized.
    #
    # This is empty by default but is present to allow plugins to tie into.
    #
    # Returns nothing.
    def after_initialize; end

    # Public: Runs the system tick function.
    #
    # context - The context object of the current tick from the game engine. In DragonRuby this is `args`.
    #
    # Returns nothing.
    def call(context)
      before_tick(context)
      tick(context)
      after_tick(context)
      self
    end

    # Public: Callback run before #tick is called.
    #
    # This is empty by default but is present to allow plugins to tie into.
    #
    # context - The context object of the current tick from the game engine. In DragonRuby this is `args`.
    #
    # Returns nothing.
    def before_tick(context); end

    # Public: Runs the System logic for the current game engine tick.
    #
    # This is where the logic is implemented and it should be overriden for each System.
    #
    # context - The context object of the current tick from the game engine. In DragonRuby this is `args`.
    #
    # Returns nothing
    def tick(context); end

    # Public: Callback run after #tick is called.
    #
    # This is empty by default but is present to allow plugins to tie into.
    #
    # Returns nothing.
    def after_tick(context); end

    # Public: Serializes the System to save the current state.
    #
    # Returns a Hash representing the System.
    def serialize
      {
        class: self.class.name.to_s,
        entities: entities.map(&:serialize),
        world: world ? world.serialize : nil
      }
    end

    # Public: Returns a String representation of the System.
    def inspect
      serialize.to_s
    end

    # Public: Returns a String representation of the System.
    def to_s
      serialize.to_s
    end
  end
end
