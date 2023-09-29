# Internal: An Array that notifies it's parent of updates.
class Draco::Entity::ComponentStore
  include Enumerable

  # Internal: Initializes a new ComponentStore
  #
  # parent - The object to notify about updates.
  def initialize(parent)
    @components = {}
    @parent = parent
  end

  # Internal: Adds Components to the ComponentStore.
  #
  # Side Effects: Notifies the parent that the components were updated.
  #
  # components - The Component or Array list of Components to add to the ComponentStore.
  #
  # Returns the ComponentStore.
  def <<(*components)
    components.flatten.each { |component| add(component) }

    self
  end

  # Internal: Returns the Component with the underscored Component name.
  #
  # underscored_component - The String underscored version of the Component's class name.
  #
  # Returns the Component instance or nil.
  def [](underscored_component)
    @components[underscored_component]
  end

  # Internal: Adds a Component to the ComponentStore.
  #
  # Side Effects: Notifies the parent that the components were updated.
  #
  # components - The Component to add to the ComponentStore.
  #
  # Returns the ComponentStore.
  def add(component)
    unless component.is_a?(Draco::Component)
      message = component.is_a?(Class) ? " You might need to initialize the component before you add it." : ""
      raise Draco::NotAComponentError, "The given value is not a component.#{message}"
    end

    component = @parent.before_component_added(component)
    name = Draco.underscore(component.class.name.to_s).to_sym
    @components[name] = component
    @parent.after_component_added(component)

    self
  end

  # Internal: Removes a Component from the ComponentStore.
  #
  # Side Effects: Notifies the parent that the components were updated.
  #
  # components - The Component to remove from the ComponentStore.
  #
  # Returns the ComponentStore.
  def delete(component)
    component = @parent.before_component_removed(component)
    name = Draco.underscore(component.class.name.to_s).to_sym
    @components.delete(name)
    @parent.after_component_removed(component)

    self
  end

  # Internal: Returns true if there are no entries in the Set.
  #
  # Returns a boolean.
  def empty?
    @components.empty?
  end

  # Internal: Returns an Enumerator for all of the Entities.
  def each(&block)
    @components.values.each(&block)
  end
end
