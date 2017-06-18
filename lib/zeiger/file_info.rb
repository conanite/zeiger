require 'set'

module Zeiger
  class FileInfo
    attr_accessor :dir, :filename, :ngrams

    def initialize dir, filename
      @dir, @filename, @ngrams = dir, filename, Set.new
    end

    def local_filename
      @_local_filename ||= filename.gsub(/^#{Regexp.escape dir}\//, "")
    end

    def match regex
      local_filename.match regex
    end

    def add_ngram ngram
      @ngrams << ngram
    end
  end
end
