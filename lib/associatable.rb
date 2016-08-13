require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
     @class_name.constantize
   end

   def table_name
     model_class.table_name
   end
end

class BelongsToOptions  < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :foreign_key => "#{name}_id".to_sym,
      :primary_key => "id".to_sym,
      :class_name => name.to_s.camelcase
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults ={
      :foreign_key => "#{self_class_name.underscore}_id".to_sym,
      :primary_key => :id,
      :class_name => name.to_s.singularize.camelcase
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable
  def belongs_to(name, options = {})
      assoc_options[name] = BelongsToOptions.new(name, options)

      define_method(name) do
        options = self.class.assoc_options[name]
        key_value = self.send(options.foreign_key)
        options.model_class.where(id: key_value).first
      end
  end

  def has_many(name, options = {})
    assoc_options[name] = HasManyOptions.new(name, self.name, options)
     define_method(name) do
       options = self.class.assoc_options[name]
       key = options.foreign_key.to_sym
       options.model_class.where("#{key}".to_sym => self.id)
     end
   end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method name do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      through_key = through_options.foreign_key
      through_pk = through_options.primary_key

      source_table = source_options.table_name
      source_pk = source_options.primary_key
      source_fk = source_options.foreign_key
      key = self.send(through_options.foreign_key)
      results = DBConnection.execute2(<<-SQL, key)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
        WHERE
          #{through_table}.#{through_pk} = ?
      SQL

      source_options.model_class.parse_all(results).last
    end
  end
end

class SQLObject
  extend Associatable
end
