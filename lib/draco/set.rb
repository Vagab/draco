module Draco
  # Internal: An implementation of Set.
  class Set
    include Enumerable

    # Internal: Initializes a new Set.
    #
    # entries - The initial Array list of entries for the Set
    def initialize(entries = [])
      @hash = {}
      merge(entries)
    end

    # Internal: Adds a new entry to the Set.
    #
    # entry - The object to add to the Set.
    #
    # Returns the Set.
    def add(entry)
      @hash[entry] = true
      self
    end

    # Internal: Adds a new entry to the Set.
    #
    # entry - The object to add to the Set.
    #
    # Returns the Set.
    def delete(entry)
      @hash.delete(entry)
      self
    end

    # Internal: Adds multiple objects to the Set.
    #
    # entry - The Array list of objects to add to the Set.
    #
    # Returns the Set.
    def merge(entries)
      Array(entries).each { |entry| add(entry) }
      self
    end

    # Internal: alias of merge
    def +(other)
      merge(other)
    end

    # Internal: Returns an Enumerator for all of the entries in the Set.
    def each(&block)
      @hash.keys.each(&block)
    end

    # Internal: Returns true if the object is in the Set.
    #
    # member - The object to search the Set for.
    #
    # Returns a boolean.
    def member?(member)
      @hash.key?(member)
    end

    # Internal: Returns true if there are no entries in the Set.
    #
    # Returns a boolean.
    def empty?
      @hash.empty?
    end

    # Internal: Returns the intersection of two Sets.
    #
    # other - The Set to intersect with
    #
    # Returns a new Set of all of the common entries.
    def &(other)
      response = Set.new
      each do |key, _|
        response.add(key) if other.member?(key)
      end

      response
    end

    def ==(other)
      hash == other.hash
    end

    # Internal: Returns a unique hash value of the Set.
    def hash
      @hash.hash
    end

    # Internal: Returns an Array representation of the Set.
    def to_a
      @hash.keys
    end

    # Internal: Serializes the Set.
    def serialize
      to_a.inspect
    end

    # Internal: Inspects the Set.
    def inspect
      to_a.inspect
    end

    # Internal: Returns a String representation of the Set.
    def to_s
      to_a.to_s
    end
  end
end
