module Zeiger
  class Line
    attr_accessor :dir, :file, :line_number, :content
    attr_reader :hash

    def initialize dir, file, line_number, content
      @dir, @file, @line_number, @content = dir, file, line_number, content
      @hash = "#{file}##{line_number}".hash
    end

    def filename fn
      fn.gsub(/^#{Regexp.escape dir}\//, "")
    end

    def to_s           ; "#{filename(file)}:#{line_number}:#{content}"                    ; end
    def matches? regex ; content.match regex                                              ; end
    def ngrams    size ; content.ngrams(size).each { |ngram| yield ngram, self }          ; end
    def ==       other ; self.file == other.file && self.line_number == other.line_number ; end
  end
end
