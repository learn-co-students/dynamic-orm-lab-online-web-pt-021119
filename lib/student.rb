require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
    self.column_names.each do |acc|
        attr_accessor acc.to_sym
    end 
end
