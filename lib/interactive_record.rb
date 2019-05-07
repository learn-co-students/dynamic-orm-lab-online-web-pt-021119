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
    columns = []

    table_info.each {|r| columns << r["name"]}

    columns.compact
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
    self.class.column_names.delete_if {|c| c == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |c|
      values << "'#{send(c)}'" if c != "id"
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert}
      (#{col_names_for_insert})
      VALUES
      (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE ? = ?
    SQL

    DB[:conn].execute(sql, name, name)
  end

  def self.find_by(attribute_hash)
      sql = <<-SQL
        SELECT *
        FROM #{table_name}
        WHERE #{attribute_hash.keys[0].to_s} = ?
      SQL
      DB[:conn].execute(sql, attribute_hash.values[0])
    end

end
