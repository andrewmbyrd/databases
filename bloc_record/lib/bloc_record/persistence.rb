require 'sqlite3'
require 'bloc_record/schema'

module Persistence
  def self.included(base)
     base.extend(ClassMethods)
  end

  def save
     self.save! rescue false
  end

  def save!
    unless self.id
       self.id = self.class.create(BlocRecord::Utility.instance_variables_to_hash(self)).id
       BlocRecord::Utility.reload_obj(self)
       return true
    end
    fields = self.class.attributes.map { |col| "#{col}=#{BlocRecord::Utility.sql_strings(self.instance_variable_get("@#{col}"))}" }.join(",")

    self.class.connection.execute <<-SQL
       UPDATE #{self.class.table}
       SET #{fields}
       WHERE id = #{self.id};
     SQL

    true
  end

  def update_attribute(attribute, value)
    self.class.update(self.id, { attribute => value })
  end

  #updates is a hash
  def update_attributes(updates)
    self.class.update(self.id, updates)
  end

  module ClassMethods
     def create(attrs)
       attrs = BlocRecord::Utility.convert_keys(attrs)
       attrs.delete "id"
       vals = attributes.map { |key| BlocRecord::Utility.sql_strings(attrs[key]) }

       connection.execute <<-SQL
         INSERT INTO #{table} (#{attributes.join ","})
         VALUES (#{vals.join ","});
       SQL

       data = Hash[attributes.zip attrs.values]
       data["id"] = connection.execute("SELECT last_insert_rowid();")[0][0]
       new(data)
     end

     #id is an integer. updates is a hash typically.
     #now for the assignment, we're updating it such that ids is an array of id's (integers) and updates is
     #an array of hashes that contain data like {attribute => value}
     def update(ids, updates)
       if ids.class == Array && updates.class == Array
         #we can assume ids and updates will be of the same length
         for i in 0...ids.length
           #for each hash in the updates array, make sure the key is of type string for the SQL query
           update = BlocRecord::Utility.convert_keys(updates[i])
           connection.execute <<-SQL
              UPDATE #{table}
              SET #{update.keys.first} = #{BlocRecord::Utility.sql_strings(update.values.first)}
              WHERE id = #{ids[i]}
           SQL
         end
       else
         updates = BlocRecord::Utility.convert_keys(updates)
         updates.delete "id"

         updates_array = updates.map {|key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }

         if ids.class == Fixnum
           where_clause = "WHERE id = #{ids};"
         elsif ids.class == Array
           where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")});"
         else
           where_clause = ";"
         end

         connection.execute <<-SQL
            UPDATE #{table}
            SET #{updates_array * ","}
            where_clause
          SQL
        end

        true
     end


     def update_all(updates)
      update(nil, updates)
    end

  end
end
