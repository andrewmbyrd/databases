require 'sqlite3'
require 'pg'

 module Connection
   def connection
     if @platform == :sqlite3
       @connection ||= SQLite3::Database.new(BlocRecord.database_filename)
     else
       @connection ||= PG::Database.new(BlocRecord.database_filename)
     end


   end
 end
