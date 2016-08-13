require 'active_support/inflector'
require 'sqlite3'
require_relative './lib/db_connection'
require_relative './lib/sql_object'
require_relative './lib/searchable'
require_relative './lib/associatable'
DBConnection::reset

class Dog < SQLObject
  finalize!
end