require 'pry'
require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = <<-SQL
    PRAGMA table_info('#{table_name}')
    SQL
    column_arry = []
    arry = DB[:conn].execute(sql)
    arry.collect do
      |row| column_arry << row["name"]
    end
    column_arry.compact
  end

def initialize(options={})
  options.each do
    |key, value| self.send("#{key}=", value)
  end

end

def table_name_for_insert
  self.class.table_name
end

def col_names_for_insert
  self.class.column_names.delete_if{|x| x == "id"}.join(", ")
end

def values_for_insert

  new_arry = []
  self.class.column_names.each do
    |att| new_arry << "'#{send(att)}'" unless send(att).nil?
  end
  new_arry.join(", ")
end

def save

  sql = <<-SQL
  INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
  SQL

  anr = DB[:conn].execute(sql)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  anr
end

def self.find_by_name(name)
  sql = <<-SQL
  SELECT * FROM #{self.table_name} WHERE name = ?
  SQL
  DB[:conn].execute(sql, name)
end

def self.find_by(sth)
  sql = "SELECT * FROM #{self.table_name} WHERE #{sth.keys[0]} = ?"
  DB[:conn].execute(sql, sth.values[0])
end

end
