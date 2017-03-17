module BlocRecord
  class Collection < Array

    #updates is an array
    def update_all(updates)
      ids = self.map(&:id)

      self.any? self.first.class.update(ids, updates) : false
    end

  end
end
