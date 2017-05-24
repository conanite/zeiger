require 'set'

module Zeiger
  class FileInfo
    attr_accessor :filename, :ngrams

    def initialize filename
      @filename = filename
      @ngrams   = Set.new
    end

    def add_ngram ngram
      @ngrams << ngram
    end
  end
end
