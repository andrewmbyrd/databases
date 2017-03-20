module BlocRecord
   def self.connect_to(filename, platform)
     @database_filename = filename
     #store the platform that the user connected to
     @platform = platform
   end

   def self.database_filename
     @database_filename
   end
end
