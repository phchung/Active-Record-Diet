require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'

def reload
  load '01_sql_object.rb'
  load '02_searchable.rb'
end


class SQLObject
  def self.columns
    return @col if @col
    col = DBConnection.execute2(<<-SQL).first
        SELECT
          *
        FROM
          #{self.table_name}
      SQL
      col.map!(&:to_sym)
    @col = col
  end

  def self.finalize!
    self.columns.each do |col|
      define_method col do
        attributes[col]
      end

      define_method "#{col}=" do |val|
        attributes[col] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
  end

  def self.all
    all = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
      SQL
      all.shift
      self.parse_all(all)
  end

  def self.parse_all(results)
    results.map {|result| self.new(result)}
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
     SELECT
       *
     FROM
       #{self.table_name}
     WHERE
       #{self.table_name}.id = ?
   SQL
    parse_all(result).first
  end

  def initialize(params = {})
    params.each do |key,val|
      if !self.class.columns.include?(key.to_sym)
        raise "unknown attribute '#{key}'"
      end
      self.send("#{key.to_sym}=",val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |col|
      self.send(col)
    end
  end

  def insert
    length = self.class.columns.length
    col_names = self.class.columns.join(',')
    question_marks = (["?"] * length).join(',')

    DBConnection.execute2(<<-SQL,*attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id  = DBConnection.last_insert_row_id
  end

  def update
    col_set = self.class.columns.map {|col| "#{col}=?"}.join(',')
    DBConnection.execute2(<<-SQL,*attribute_values,self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_set}
      WHERE
        id = ?
    SQL
  end

  def save
    self.id.nil? ? insert : update
  end
end

class Cat < SQLObject
  finalize!
end
