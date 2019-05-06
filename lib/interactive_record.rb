require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    columns = []
    sql = "PRAGMA table_info(#{table_name})" # No self required in class scope
    DB[:conn].execute(sql).each do |hash|
      columns << hash['name']
    end
    columns.compact # .compact removes nil values
  end

  def initialize(options={})
    options.each {|key, value|
      self.send("#{key}=", value)
    }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == 'id'}.join(', ')
    # we NEVER want to write the id value
  end

  def values_for_insert
    # envoke send method to programmatically grab attr_accessors
    values = []
    self.class.column_names.each {|val| values << "'#{send(val)}'" unless send(val).nil?}
    values.join(', ')
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attr)
    row = []
    attr.each do |key, val|
      sql = "SELECT * FROM #{table_name} WHERE #{key.to_s} = ?"
      row = DB[:conn].execute(sql, val.to_s)
    end
    row
  end

end
