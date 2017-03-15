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
    #error handling/input validation
    raise IDError "Invalid input" unless num.is_a?(Numeric) && num > 0

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
      FROM #{table}
    SQL

    rows_to_array(rows)
  end

  def find(*ids)
    #error handling/input validation
    ids.each_with_index do |id, index|
      raise IDError, "ID at position #{index} is not a number" unless id.is_a?(Numeric) && id > 0
    end

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
      #error handling/input validation
      raise IDError "Invalid input" unless num.is_a?(Numeric) && num > 0

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

  #assignment problem. We make start and batch_size optional arguments
  def find_each(start = nil, batch_size = nil)
    #if we have both arguments, we want to grab every record from the provided start ID up to start + batch_size
    #set rows equal to the query.
    if start && batch_size
      finish = start + batch_size
      range = []
      for i in start..finish
        range << i
      end
      rows = connection.execute <<-SQL
        SELECT *
        FROM #{table}
        WHERE id IN (#{range.join(",")})
        ORDER BY id;
      SQL
    #if neither arguments is given we put the entire table into rows
    elsif !start && !batch_size
      rows = connection.execute <<-SQL
        SELECT *
        FROM #{table}
        ORDER BY id;
      SQL
    #if one argument is provided but not the other, then we raise an error
    else
      raise ArgsError "Wrong Number of Arguments given"
    end

    #records will be an array of Hash objects
    records = rows_to_array(rows)

    #yield every record to the user to perform their block on
    for i in 0...records.length
      yield records[i]
    end
  end

  #it looks like this just does one step less than the method above. don't iterate through `records` and yield each one,
  #just yield the entire array of objects.
  #start and batch_size are both required in this one
  def find_in_batches(start, batch_size)
    finish = start + batch_size
    range = []
    for i in start..finish
      range << i
    end
    rows = connection.execute <<-SQL
      SELECT *
      FROM #{table}
      WHERE id IN (#{range.join(",")})
      ORDER BY id;
    SQL

    records = rows_to_array(rows)

    yield records
  end

  private

  def init_object_from_row(row)
     if row
       data = Hash[columns.zip(row)]
       new(data)
     end
  end

  def rows_to_array(rows)
    rows.map { |row| new(Hash[columns.zip(row)])}
  end

  class IDError < StandardError
  end

  class ArgsError < StandardError
  end
end
