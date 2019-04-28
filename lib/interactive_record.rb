require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"
    col_names = []
    DB[:conn].execute(sql).each do |hash|
      col_names << hash["name"]
    end
    col_names.compact
  end

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|x| x == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name_arg)
    sql = "SELECT * FROM #{table_name} WHERE name = '#{name_arg}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attr)
    col = attr.keys.first.to_s
    val = attr.values.first.to_s
    sql = "SELECT * FROM #{table_name} WHERE #{col} = '#{val}'"
    DB[:conn].execute(sql)
  end

end
