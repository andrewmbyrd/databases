module BlocRecord
   class Collection < Array

     #specificatin is of type String
     def where(specifation)
       #we'll return another object of type Collection if there is anything that meets the further search terms
       #it starts out as empty

       response = Collection.new


       words = specifation.split(" ")
       #gets the attribute
       attribute = words[0]
       #gets the relation. We have to assume this is going to be `IS` or `=` or '!=' or `IS NOT`
       relation = words[1]
       #then we'll set value to whatever is on the right hand side of the relation. Join back up at spaces in case
       #there were any in the original specifation
       if words[2] == "NOT"
         relation += " NOT"
         value = words.slice(3, words.length).join(" ")
       else
         value = words.slice(2, words.length).join(" ")
       end

       self.each do |entry|
         case relation
         when "IS" || "="
           response << entry if entry[attribute] == value
         end
       end

       response
     end

   end
 end
