require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        sql="PRAGMA table_info(#{self.table_name})"
        col_names=[]
        col_names=DB[:conn].execute(sql).map{|a|a["name"]}.compact
    end

    def initialize (attributes={})
        attributes.each do |k,v|
            self.send("#{k}=",v)
        end
    end
    
    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        (self.class.column_names-["id"]).join(", ")
    end

    def values_for_insert
        self.col_names_for_insert.split(', ').map {|col|"'#{self.send(col)}'"}.join(", ")
    end

    def save
        sql="INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id=DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name (name)
        sql="SELECT * FROM #{self.table_name} WHERE name=? LIMIT 1"
        DB[:conn].execute(sql,name)
    end

    def self.find_by(att)
        sql="SELECT * FROM #{self.table_name} WHERE #{att.keys.first.to_s}=? LIMIT 1"
        DB[:conn].execute(sql,att.values.first.to_s)
    end

end