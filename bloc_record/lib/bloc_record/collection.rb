module BlocRecord
  class Collection < Array

    #updates is an array
    def update_all(updates)
      ids = self.map(&:id)

      self.any? self.first.class.update(ids, updates) : false
    end

    #we already have all of the elements from the initial where clause in this array: self
    #so just return a random element from self
    def take
      self.sample
    end

    #specification is a hash
    def where(specification)
      #our response is going to be again of type collection. Initially it's empty
      response = Collection.new

      #we already have the complete list of what could be returned by further specifications
      #here, we can loop through each Entry in SELF and see if its VALUE at KEY matches. if it does,
      #append it to response
      key = specification.keys.first
      value = specification.values.first
      self.each do |entry|
        response << entry if entry.key == value
      end

      response.empty? ? nil : response
    end

  end
end
