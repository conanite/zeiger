require "zeiger/version"
require "set"

class String
  def ngrams size
    padding = " " * (size - 1)
    # txt = "#{padding}#{self}#{padding}"
    txt = self
    ngrams = Hash.new { |h,k| h[k] = 0 }
    regex = Regexp.compile("." * size)

    result = []

    while txt.length > 0
      match = txt.match(regex).to_s
      result << match unless match == ""
      txt = txt[1..-1]
    end

    result
  end
end

module Zeiger
  class Index
    INCLUDES   = %w{ app bin config db/migrate db/schema.rb lib public/javascripts public/stylesheets spec }
    NGRAM_SIZE = 3

    attr_accessor :index, :dir

    def initialize dir
      self.index = build_index(dir, Hash.new { |h, k| h[k] = Set.new })
    end

    def build_index(dir, idx)
      INCLUDES.each do |inc|
        Dir.glob(File.join(dir, inc, "**")).each do |file|
          if File.file? file
            puts "indexing #{file}"
            File.read(file).split(/\n/).each_with_index { |txt, line|
              Line.new(file, line, txt).ngrams(NGRAM_SIZE) { |trig, line| idx[trig] << line }
            }
          end
        end
      end
      puts "finished indexing, #{idx.length} ngrams"
      puts idx.keys.inspect
      idx
    end

    def exec_query regex, ngrams
      ngrams.map { |ngram| index[ngram] }.reduce(&:&).select { |line| line.matches? regex }
    end

    def query txt
      puts "got query #{txt.inspect}"
      exec_query Regexp.compile(txt), txt.ngrams(NGRAM_SIZE)
    end
  end

  class Line
    attr_accessor :file, :line_number, :content
    attr_reader :hash

    def initialize file, line_number, content
      @file, @line_number, @content = file, line_number, content
      @hash = "#{file}##{line_number}".hash
    end

    def to_s           ; "#{file}:#{line_number}:    #{content}"                          ; end
    def matches? regex ; content.match regex                                              ; end
    def ngrams    size ; content.ngrams(size).each { |ngram| yield ngram, self }          ; end
    def ==       other ; self.file == other.file && self.line_number == other.line_number ; end
  end
end
