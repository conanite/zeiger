module Zeiger
  INDICES = { }

  class Index
    ROOT_FILES = %w{ .zeiger.yml .git .hg Makefile Rakefile Gemfile build.xml }
    NGRAM_SIZE = 3

    attr_accessor :index, :dir, :includes, :ignore, :files, :monitor

    def initialize dir
      attrs = File.exist?(".zeiger.yml") ? YAML.load(File.read ".zeiger.yml") : { }
      self.dir      = File.expand_path dir
      self.index    = Hash.new { |h, k| h[k] = [] }
      self.files    = Hash.new
      self.monitor  = Monitor.new dir, self
      rescan
    end

    def self.from_path path
      raise "no path! #{path.inspect}" if path == nil || path.strip == ''
      return INDICES[path] if INDICES[path]
      return nil if path == '/'
      return (INDICES[path] = new(path)) if ROOT_FILES.any? { |f| File.exist?(File.join path, f) }
      return from_path(File.dirname path)
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

    def rescan                   ; monitor.build_index                                            ; end
    def get_ngram_lines   ngrams ; ngrams.map { |ngram| result = index[ngram] || [] }.reduce(&:&) ; end
    def exec_query regex, ngrams ; get_ngram_lines(ngrams).select { |line| line.matches? regex }  ; end
    def sort_by_filename   lines ; lines.sort_by { |line| line.file.local_filename }              ; end

    def query txt
      puts "got query #{txt.inspect}"
      sort_by_filename exec_query Regexp.compile(Regexp.escape txt), txt.ngrams(NGRAM_SIZE)
    end

    def file_list name
      if name
        r = Regexp.compile name
        puts "file names matching #{r.inspect}"
        files.values.select { |f| f.match r }
      else
        files.values
      end.sort_by { |f| f.local_filename.length }
    end
  end
end
