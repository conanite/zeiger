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
          index[ngram].reject! { |line| line.file == info }
        }
      end
      files.delete file
    end

    def add_to_index file
      info = files[file] = FileInfo.new(dir, file)

      File.read(file).split(/\n/).each_with_index { |txt, line|
        Line.new(info, line + 1, txt).ngrams(NGRAM_SIZE) do |trig, line|
          index[trig] << line
          info.add_ngram trig
        end
      }
    end

    def exec_query regex, ngrams
      ngrams.map { |ngram| result = index[ngram] || [] }.reduce(&:&).select { |line| line.matches? regex }
    end

    def query txt
      puts "got query #{txt.inspect}"
      exec_query Regexp.compile(Regexp.escape txt), txt.ngrams(NGRAM_SIZE)
    end

    def file_list name
      if name
        r = Regexp.compile name
        puts "file names matching #{r.inspect}"
        files.values.select { |f| f.match r }
      else
        files.values
      end.sort_by { |f| f.local_filename }
    end
  end
end
