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

  def destroy
    self.class.destroy(self.id)
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

     #id is an integer. updates is a hash
     def update(ids, updates)
       updates = BlocRecord::Utility.convert_keys(updates)
       updates.delete "id"

       updates_array = updates.map {|key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }

       if ids.class == Fixnum
         where_clause = "WHERE id = #{ids};"
       elsif ids.class == array
         where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")});"
       else
         where_clause = ";"
       end

       connection.execute <<-SQL
          UPDATE #{table}
          SET #{updates_array * ","}
          where_clause
        SQL

        true
     end


    def update_all(updates)
      update(nil, updates)
    end

    def destroy(*id)
      if id.length > 1
        where_clause = "id IN (#{id.join(",")});"
      else
        where_clause = "id = #{id[0]};"
      end

      connection.execute <<-SQL
        DELETE
        FROM #{table}
        WHERE where_clause
      SQL

      true
    end

    #use the splat operator to turn any arguments into an array
    def destroy_all(*conditions_argument)
      #if the array length is > 1, then the function call intended to use a prepared statement
      #to execute the SQL. Set up the expression as the string at index 0, and all of the values
      #are the strings in the remaining indices
      if conditions_argument.length > 1
        expression = conditions_argument.shift
        params = conditions_argument

      #if our argument is of length 1, the problem was to incorporate a String. We also have to remember the case
      #of a Hash from the checkpoint
      elsif conditions_argument.length == 1
        case conditions_argument.first

        when Hash
          conditions_hash = BlocRecord::Utility.convert_keys(conditions_hash)
          expression = conditions_hash.map {|key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")

        when String
          expression = conditions_argument.first
        end
      #this `else` means our conditions_argument is empty. delete everything and return true
      else
        connection.execute <<-SQL
          DELETE FROM #{table}
        SQL
        return true
      end

      #now if there was anything provided to the conditions_argument, we have expression and possibly params established
      #we can prepare the SQL statement
      sql = <<-SQL
        DELETE FROM #{table}
        WHERE #{expression}
      SQL

      #if params were provided with an array, we have to do connection.execute. This statement also seems to work if
      #params is nil
      connection.execute(sql, params)
      return true

    end

  end
end
