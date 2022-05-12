
module Zeiger
  DB_FILENAME = "/tmp/zeiger.db"

  SCHEMA = {
    indices:  { id: :"integer primary key", root: :text },
    files:    { id: :"integer primary key", index_id: :integer, path: :text, updated_at: :numeric },
    lines:    { id: :"integer primary key", file_id: :integer, lineno: :integer, content: :text },
    trigrams: { id: :text, line_id: :integer },
  }

  class Database

    def initialize
      @sem = Mutex.new
      @db = SQLite3::Database.new "/tmp/zeiger.db"

      @types = SCHEMA.each_with_object({}) { |(tbl, dfn), h|
        h[tbl] = dfn.keys
      }

      SCHEMA.each { |sch, dfn|
        dfn = dfn.map { |col, typ| "#{col} #{typ}" }.join(", ")
        stm = "create table if not exists #{sch} (#{dfn})"
        puts stm
        @db.execute stm
      }
    end

    def select tbl, conditions
      @sem.synchronize do
        where = conditions.map { |col, val| "#{col}=#{val.inspect}" }.join(" AND ")
        sql   = "select * from #{tbl} where #{where}"
        rows  = @db.execute sql
        sch   = @types[tbl]
        rows.map { |r| sch.zip(r).to_h }
      end
    end
  end
end
