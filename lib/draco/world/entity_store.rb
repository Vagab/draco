# Internal: Stores Entities with better performance than Array.
class Draco::World::EntityStore
  include Enumerable

  attr_reader :parent

  # Internal: Initializes a new EntityStore
  #
  # entities - The Entities to add to the EntityStore
  def initialize(parent, *entities)
    @parent = parent
    @entity_to_components = Hash.new { |hash, key| hash[key] = Set.new }
    @component_to_entities = Hash.new { |hash, key| hash[key] = Set.new }
    @entity_ids = {}

    self << entities
  end

  # Internal: Gets all Entities that implement all of the given Components or that match the given entity ids.
  #
  # components_or_ids - The Component Classes to filter by
  #
  # Returns a Set list of Entities
  def [](*components_or_ids)
    components_or_ids
      .flatten
      .map { |component_or_id| select_entities(component_or_id) }
      .reduce { |acc, i| i & acc }
  end

  # Internal: Gets entities by component or id.
  #
  # component_or_id - The Component Class or entity id to select.
  #
  # Returns an Array of Entities.
  def select_entities(component_or_id)
    if component_or_id.is_a?(Numeric)
      Array(@entity_ids[component_or_id])
    else
      @component_to_entities[component_or_id]
    end
  end

  # Internal: Adds Entities to the EntityStore
  #
  # entities - The Entity or Array list of Entities to add to the EntityStore.
  #
  # Returns the EntityStore
  def <<(entities)
    Array(entities).flatten.each { |e| add(e) }
    self
  end

  # Internal: Adds an Entity to the EntityStore.
  #
  # entity - The Entity to add to the EntityStore.
  #
  # Returns the EntityStore
  def add(entity)
    entity.subscribe(self)

    @entity_ids[entity.id] = entity
    components = entity.components.map(&:class)
    @entity_to_components[entity].merge(components)

    components.each { |component| @component_to_entities[component].add(entity) }
    entity.components.each { |component| @parent.component_added(entity, component) }

    self
  end

  # Internal: Removes an Entity from the EntityStore.
  #
  # entity - The Entity to remove from the EntityStore.
  #
  # Returns the EntityStore
  def delete(entity)
    @entity_ids.delete(entity.id)
    components = Array(@entity_to_components.delete(entity))

    components.each do |component|
      @component_to_entities[component].delete(entity)
    end
  end

  # Internal: Returns true if the EntityStore has no Entities.
  def empty?
    @entity_to_components.empty?
  end

  # Internal: Returns an Enumerator for all of the Entities.
  def each(&block)
    @entity_to_components.keys.each(&block)
  end

  # Internal: Updates the EntityStore when an Entity's Components are added.
  #
  # entity - The Entity the Component was added to.
  # component - The Component that was added to the Entity.
  #
  # Returns nothing.
  def component_added(entity, component)
    @component_to_entities[component.class].add(entity)
    @parent.component_added(entity, component)
  end

  # Internal: Updates the EntityStore when an Entity's Components are removed.
  #
  # entity - The Entity the Component was removed from.
  # component - The Component that was removed from the Entity.
  #
  # Returns nothing.
  def component_removed(entity, component)
    @component_to_entities[component.class].delete(entity)
    @parent.component_removed(entity, component)
  end
end
