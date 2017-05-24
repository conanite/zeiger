module Zeiger
  class Index
    NGRAM_SIZE = 3

    attr_accessor :index, :dir, :includes, :ignore

    def initialize dir
      attrs = File.exist?(".zeiger.yml") ? YAML.load(File.read ".zeiger.yml") : { }
      self.dir      = File.expand_path dir
      self.index    = Hash.new { |h, k| h[k] = Set.new }
    end

    def remove_from_index file
      index.values.each { |set| set.reject! { |line| line.file == file } }
    end

    def add_to_index file
      File.read(file).split(/\n/).each_with_index { |txt, line|
        Line.new(dir, file, line, txt).ngrams(NGRAM_SIZE) { |trig, line| index[trig] << line }
      }
    end

    def exec_query regex, ngrams
      ngrams.map { |ngram| index[ngram] }.reduce(&:&).select { |line| line.matches? regex }
    end

    def query txt
      puts "got query #{txt.inspect}"
      exec_query Regexp.compile(txt), txt.ngrams(NGRAM_SIZE)
    end
  end
end
