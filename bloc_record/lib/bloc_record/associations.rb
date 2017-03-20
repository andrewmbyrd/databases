require 'sqlite3'
require 'pg'
require 'active_support/inflector'

module Associations

  def has_many(association)

    define_method(association) do
      rows = self.class.connection.exeute <<-SQL
        SELECT *
        FROM #{association.to_s.singularize}
        WHERE #{self.class.table}_id = #{self.id};
      SQL

      class_name = association.to_s.classify.constantize
      collection = BlocRecord::Collection.new

      rows.each do |row|
        collection << class_name.new(Hash[class_name.columns.zip(row)])
      end

      collection

    end
  end


  def belongs_to(association)

    define_method(association) do
      association_name = association.to_s
      row = self.class.connection.get_first_row <<-SQL
        SELECT *
        FROM #{association_name}
        WHERE id = #{self.send(association_name + "_id")};
      SQL

      class_name = association_name.classify.constantize

      if row
        data = Hash[class_name.columns.zip(row)]
        class_name.new(data)
      end
    end

  end

  #getting has_one for the assignment
  def has_one(association)

    #create an instance method with the name of whatever the association is that the instance has one of
    #for instance we might declare in a Person class: has_one :address. this would allow any instance of a Person
    #to do p.address, which would yield an Address object, if that relation exists in the database
    define_method(association) do

      #for example, this line would set association_name to 'address' if the argument was :address
      association_name = association.to_s

      #by definition, we'll only have one valid row. We want to find that in the `association` table.
      #In that table,  there will be a column named `self.class.table_id` if the relationship exists.
      #in that column, there needs to be a match on the id of whatever instance of whatever class is calling this
      row = self.class.connection.get_first_row <<-SQL
        SELECT *
        FROM #{association_name}
        WHERE #{self.class.table}_id = #{self.id};
      SQL

      #format the name correctly and return a new instance of that object if the relationship existed in the database
      class_name = association_name.classify.constantize

      if row
        data = Hash[class_name.columns.zip(row)]
        class_name.new(data)
      end

    end

  end

end
