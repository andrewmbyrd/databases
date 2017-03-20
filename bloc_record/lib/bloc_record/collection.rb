module BlocRecord
  class Collection < Array

    #updates is an array
    def update_all(updates)
      ids = self.map(&:id)

      self.any? self.first.class.update(ids, updates) : false
    end

    #self is a Collection (which is essentially an Array) containing instances of Entry at each index
    #for each instance in Self, we can call the Entry instance method #destroy, which will call the class
    #method #destroy, which will use the instance's id to find it in the table and delete it with a DELETE FROM
    def destroy_all
      self.each do |entry|
        entry.destroy
      end
    end

  end
end
