require 'sqlite3'

module Selection

  def take_one
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join(",")}
      FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def take(num)
    if num > 1
      rows = connection.execute <<-SQL
        SELECT #{columns.join(",")}
        FROM #{table}
        ORDER BY random()
        LIMIT #{num};
      SQL

      rows_to_array(rows)
    else
      take_one
    end
  end

  def where(*args)
    if args.count > 1
      expression = args.shift
      params = args
    else
      case args.first
      when String
        expression = args.first
      end
      when Hash
        expression_hash = BlocRecord::Utility.convert_keys(args.first)
        expression = expression_hash.map {|key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")
    end

    sql = <<-SQL
      SELECT #{columns.join(",")}
      FROM #{table}
      WHERE #{expression};
    SQL
    #so i guess it's fine if params is nil?
    rows = connection.execute(sql, params)
    rows_to_array(rows)
  end

  def order(*args)
    order = []

    #convert everything to the proper string and put it in the array
    args.each do |arg|
      case arg
      when String
        order << arg
      when Symbol
        order << arg.to_s
      when Hash
        arg.keys.each do |key|
          order << "#{key.to_s} #{arg[key].to_s}"
        end
      end
    end

    #join that with commas to make the proper sequel join statement
    order = order.join(",")

    rows = connection.execute <<-SQL
      SELECT *
      FROM #{table}
      ORDER BY #{order};
    SQL

    rows_to_array(rows)
  end

  def join(*args)
    if args.count > 1
       joins = args.map { |arg| "INNER JOIN #{arg} ON #{arg}.#{table}_id = #{table}.id"}.join(" ")
       rows = connection.execute <<-SQL
         SELECT *
         FROM #{table}
         #{joins};
       SQL
     else
       case args.first
       when String
         rows = connection.execute <<-SQL
           SELECT *
           FROM #{table}
           #{BlocRecord::Utility.sql_strings(args.first)};
         SQL
       when Symbol
         rows = connection.execute <<-SQL
           SELECT *
           FROM #{table}
           INNER JOIN #{args.first} ON #{args.first}.#{table}_id = #{table}.id;
         SQL
      #this now handles the nested association mentioned in the assignment
       when Hash
         rows = connection.execute <<-SQL
          SELECT *
          FROM #{table}
          INNER JOIN #{args.first.keys.first} ON #{args.first.keys.first}.#{table}_id = #{table}.id
          INNER JOIN #{args.first.values.first} ON #{args.first.values.first}.#{args.first.keys.first}_id = #{args.first.keys.first}.id;
        SQL

       end
     end

    rows_to_array(rows)
  end

  def first
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join(",")}
      FROM #{table}
      ORDER BY id ASC
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join(",")}
      FROM #{table}
      ORDER BY id DESC
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def all
    rows = connection.execute <<-SQL
      SELECT #{columns.join(",")}
      FROM #{table};
    SQL

    rows_to_array(rows)
  end

  def find(*ids)
    if ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join(",")}
        FROM #{table}
        WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end

  end

  def find_one(id)
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE id = #{id};
    SQL

    init_object_from_row(row)
  end



   def find_by(attribute, value)
     row = connection.get_first_row <<-SQL
        SELECT #{columns.join ","}
        FROM #{table}
        WHERE #{attribute} = #{BlocRecord::Utitlity.sql_strings(value)};
      SQL

      data = Hash[columns.zip(row)]
      new(data)
   end

   private

  def init_object_from_row(row)
     if row
       data = Hash[columns.zip(row)]
       new(data)
     end
  end

  def rows_to_array(rows)
    collection = BlocRecord::Collection.new
    rows.each { |row| collection << new(Hash[columns.zip(row)]) }
    collection
  end

end
