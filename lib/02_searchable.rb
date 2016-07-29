require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.map {|key,val| "#{key} = ?"}.join(' AND ')

    result = DBConnection.execute2(<<-SQL,*params.values)
        SELECT
          *
        FROM
          #{self.table_name}
        WHERE
          #{where_line}
      SQL
    result.shift
    parse_all(result)
  end
end

class SQLObject
  extend Searchable
end
