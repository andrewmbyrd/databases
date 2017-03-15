module BlocRecord
  module Utility
#   #1
    extend self

    def underscore(camel_cased_word)
#      #2
       string = camel_cased_word.gsub(/::/, '/')
#      #3
       string.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
#      #4
       string.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
#      #5
       string.tr!("-", "_")
#      #6
       string.downcase
    end

    def camelize(snake_word)
      word = ""
      for i in 0...snake_word.length
        if snake_word[i-1] =="_"
          word += snake_word[i].capitalize
        elsif snake_word[i] != "_"
          word += snake_word[i]
        end
      end

      #optionally capitalize the first letter of the returned word
      #word.capitalize!
      word
    end

    def sql_strings(value)
       case value
       when String
         "'#{value}'"
       when Numeric
         value.to_s
       else
         "null"
       end
    end

    def convert_keys(options)
       options.keys.each {|k| options[k.to_s] = options.delete(k) if k.kind_of?(Symbol)}
       options
    end

    def instance_variables_to_hash(obj)
       Hash[obj.instance_variables.map{ |var| ["#{var.to_s.delete('@')}", obj.instance_variable_get(var.to_s)]}]
    end

    def reload_obj(dirty_obj)
       persisted_obj = dirty_obj.class.find_one(dirty_obj.id)
       dirty_obj.instance_variables.each do |instance_variable|
         dirty_obj.instance_variable_set(instance_variable, persisted_obj.instance_variable_get(instance_variable))
       end
    end

  end
end
