module Zeiger
  class Line
    attr_accessor :file, :line_number, :content
    attr_reader :hash

    def initialize file, line_number, content
      @file, @line_number, @content = file, line_number, content
      @hash = "#{file.filename}##{line_number}".hash
    end

    def to_s            ; "#{file.local_filename}:#{line_number}:#{content}"               ; end
    def matches? regex  ; content.match regex                                              ; end
    def ngram_list size ; @ngrams ||= content.ngrams(size)                                 ; end
    def ngrams    size  ; ngram_list(size).each { |ngram| yield ngram, self }              ; end
    def ==       other  ; self.file == other.file && self.line_number == other.line_number ; end
  end
end
