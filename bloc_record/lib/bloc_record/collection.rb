module BlocRecord
   class Collection < Array

     #specification is of type String or Hash
     def where(specifation)
       #we'll return another object of type Collection if there is anything that meets the further search terms
       #it starts out as empty
       response = Collection.new

       case specifation
       when String
         words = specifation.split(" ")
         #gets the attribute
         attribute = words[0]
         #gets the relation. We have to assume this is going to be `IS` or `=` or '!=' or `IS NOT` or "<" or '>' or '>=' or '<='
         relation = words[1]
         #then we'll set value to whatever is on the right hand side of the relation. Join back up at spaces in case
         #there were any in the original specifation
         if words[2] == "NOT"
           relation += " NOT"
           value = words.slice(3, words.length).join(" ")
         else
           value = words.slice(2, words.length).join(" ")
         end

         #append this record to our new Collection if its value relates to the attribute in the correct way
         self.each do |record|
           case relation
           when "IS" || "="
             response << record if record[attribute] == value
           when "IS NOT" || "!="
             response << record if record[attribute] != value
           when ">"
             response << record if record[attribute] > value
           when "<"
             response << record if record[attribute] < value
           when "<="
             response << record if record[attribute] <= value
           when ">="
             response << record if record[attribute] >= value
           end

         end
      #the case of a Hash is simpler; we know the user wants the key to equal the value
       when Hash
         attribute = specification.keys.first.to_s
         value = specification.values.first

         self.each do |record|
           response << record if record[attribute] == value
         end
       end

       response
     end

   end
 end
