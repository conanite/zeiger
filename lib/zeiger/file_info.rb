require 'set'

module Zeiger
  class FileInfo
    attr_accessor :index, :filename, :ngrams, :lines, :stats_group, :comment_regexes, :nc_nb_line_count

    def initialize index, filename, stats
      @index, @filename, @ngrams, @lines = index, filename, Set.new, []
      @stats_group      = stats.stats_group filename
      @comment_regexes  = stats.comment_rules(filename)
      @nc_nb_line_count = 0
    end

    def local_filename
      @_local_filename ||= filename.gsub(/^#{Regexp.escape index.dir}\//, "")
    end

    def match regex
      local_filename.match regex
    end

    def add_ngram ngram
      @ngrams << ngram
    end

    def add_line line
      lines << line
      @nc_nb_line_count += 1 unless line.blank? || (comment_regexes.any? { |regex| line.matches? regex })
    end

    def summary
      "[#{index.name}] #{stats_group}\t#{nc_nb_line_count}/#{lines.count}\t: #{local_filename}"
    end
  end
end
