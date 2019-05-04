require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    columns = []
    sql = "PRAGMA TABLE_INFO(#{self.table_name});"
    result = DB[:conn].execute(sql)
    result.each {|col| columns << col["name"] }
    columns
  end

  def initialize(options = {})
    options.each do |attribute, data|
      self.send("#{attribute}=", data)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    columns = []
    self.class.column_names.each do |col|
      columns << col unless col == "id"
    end
    columns.join(", ")
  end

  def values_for_insert
    data = []
    self.class.column_names.each do |col|
      data << col unless col == "id"
    end
    values = []
    data.each do |value|
      values << self.send("#{value}")
    end
    values.collect {|value| "'#{value}'"}.join(", ")
  end

  def save
    # binding.pry
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert})
      VALUES (#{self.values_for_insert});
    SQL
    DB[:conn].execute(sql)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() from #{self.class.table_name}").first["last_insert_rowid()"]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, "#{name}")
  end

  def self.find_by(hash)
    attribute = hash.keys.first.to_s
    query = hash.values.first
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{attribute} = "#{query}";
    SQL

    result = DB[:conn].execute(sql)
  end
end
