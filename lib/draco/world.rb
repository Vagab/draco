 # Public: The container for current Entities and Systems.
class Draco::World
  @default_entities = []
  @default_systems = []

  # Internal: Resets the default components for each class that inherites Entity.
  #
  # sub - The class that is inheriting Entity.
  #
  # Returns nothing.
  def self.inherited(sub)
    super
    sub.instance_variable_set(:@default_entities, [])
    sub.instance_variable_set(:@default_systems, [])
  end

  # Public: Adds a default Entity to the World.
  #
  # entity - The class of the Entity to add by default.
  # defaults - The Hash of default values for the Entity. (default: {})
  #
  # Examples
  #
  #   entity(Player)
  #
  #   entity(Player, position: { x: 0, y: 0 })
  #
  # Returns nothing.
  def self.entity(entity, defaults = {})
    name = defaults[:as]
    @default_entities.push([entity, defaults])

    attr_reader(name.to_sym) if name
  end

  # Public: Adds default Systems to the World.
  #
  # systems - The System or Array list of System classes to add to the World.
  #
  # Examples
  #
  #   systems(RenderSprites)
  #
  #   systems(RenderSprites, RenderLabels)
  #
  # Returns nothing.
  def self.systems(*systems)
    @default_systems += Array(systems).flatten
  end

  class << self
    # Internal: Returns the default Entities for the class.
    attr_reader :default_entities

    # Internal: Returns the default Systems for the class.
    attr_reader :default_systems
  end

  # Public: Returns the Array of Systems.
  attr_reader :systems

  # Public: Returns the Array of Entities.
  attr_reader :entities

  # Public: Initializes a World.
  #
  # entities - The Array of Entities for the World (default: []).
  # systems - The Array of System Classes for the World (default: []).
  def initialize(entities: [], systems: [])
    default_entities = self.class.default_entities.map do |default|
      klass, attributes = default
      name = attributes[:as]
      entity = klass.new(attributes)
      instance_variable_set("@#{name}", entity) if name

      entity
    end

    @entities = EntityStore.new(self, default_entities + entities)
    @systems = self.class.default_systems + systems
    after_initialize
  end

  # Public: Callback run after the world is initialized.
  #
  # This is empty by default but is present to allow plugins to tie into.
  #
  # Returns nothing.
  def after_initialize; end

  # Public: Callback run before #tick is called.
  #
  # context - The context object of the current tick from the game engine. In DragonRuby this is `args`.
  #
  # Returns the systems to run during this tick.
  def before_tick(_context)
    systems.map do |system|
      entities = filter(system.filter)

      system.new(entities: entities, world: self)
    end
  end

  # Public: Runs all of the Systems every tick.
  #
  # context - The context object of the current tick from the game engine. In DragonRuby this is `args`.
  #
  # Returns nothing
  def tick(context)
    results = before_tick(context).map do |system|
      system.call(context)
    end

    after_tick(context, results)
  end

  # Public: Callback run after #tick is called.
  #
  # This is empty by default but is present to allow plugins to tie into.
  #
  # context - The context object of the current tick from the game engine. In DragonRuby this is `args`.
  # results - The System instances that were run.
  #
  # Returns nothing.
  def after_tick(context, results); end

  # Public: Callback to run when a component is added to an existing Entity.
  #
  # entity - The Entity the Component was added to.
  # component - The Component that was added to the Entity.
  #
  # Returns nothing.
  def component_added(entity, component); end

  # Public: Callback to run when a component is added to an existing Entity.
  #
  # entity - The Entity the Component was removed from.
  # component - The Component that was removed from the Entity.
  #
  # Returns nothing.
  def component_removed(entity, component); end

  # Public: Finds all Entities that contain all of the given Components.
  #
  # components - An Array of Component classes to match.
  #
  # Returns an Array of matching Entities.
  def filter(*components)
    entities[components.flatten]
  end

  # Public: Serializes the World to save the current state.
  #
  # Returns a Hash representing the World.
  def serialize
    {
      class: self.class.name.to_s,
      entities: @entities.map(&:serialize),
      systems: @systems.map { |system| system.name.to_s }
    }
  end

  # Public: Returns a String representation of the World.
  def inspect
    serialize.to_s
  end

  # Public: Returns a String representation of the World.
  def to_s
    serialize.to_s
  end
end
