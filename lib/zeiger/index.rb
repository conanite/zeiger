module Zeiger
  class Index
    NGRAM_SIZE = 3

    attr_accessor :index, :dir, :includes, :ignore, :files

    def initialize dir
      attrs = File.exist?(".zeiger.yml") ? YAML.load(File.read ".zeiger.yml") : { }
      self.dir      = File.expand_path dir
      self.index    = Hash.new { |h, k| h[k] = [] }
      self.files    = Hash.new
    end

    def remove_from_index file
      info = files[file]
      if info
        info.ngrams.each { |ngram|
          index[ngram].reject! { |line| line.file == file }
        }
      end
    end

    def add_to_index file
      info = FileInfo.new file
      files[file] = info

      File.read(file).split(/\n/).each_with_index { |txt, line|
        Line.new(dir, file, line + 1, txt).ngrams(NGRAM_SIZE) do |trig, line|
          index[trig] << line
          info.add_ngram trig
        end
      }
      puts "#{index.length} trigrams"
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
