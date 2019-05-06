require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each {|row| column_names << row["name"]}
    column_names.compact
  end

  def initialize(hash={})
    hash.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|x| x=='id'}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |attribute|
      values << "'#{send(attribute)}'" unless send(attribute).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert}
    (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM #{table_name}
    WHERE name = ?
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    attr_key = attribute.map{|key,value| key}[0].to_s
    attr_value = attribute.map{|key,value| value}[0].to_s
    sql = <<-SQL
    SELECT *
    FROM #{table_name}
    WHERE #{attr_key} = "#{attr_value}"
    SQL
    DB[:conn].execute(sql)
  end

end
