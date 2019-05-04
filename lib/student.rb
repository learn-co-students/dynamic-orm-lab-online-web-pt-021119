require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord

  self.column_names.each do |column|
    attr_accessor column.to_sym
  end
end
