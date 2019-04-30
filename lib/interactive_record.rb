require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    columns = []

    table_info.each {|c| columns << c["name"]}

    columns.compact
  end

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.table_name_for_insert
  end

end
