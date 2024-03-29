module Zeiger
  INDICES = { }

  class Index
    ROOT_GLOBS  = [%w{ *.gemspec       }]
    ROOT_GROUPS = [%w{ .zeiger.yml     },
                   %w{ .git            },
                   %w{ .hg             },
                   %w{ Makefile        },
                   %w{ Rakefile        },
                   %w{ Gemfile         },
                   %w{ build.xml       },
                   %w{ lib LICENSE     },
                   %w{ lib spec        },
                   %w{ lib MIT-LICENSE },
                   %w{ lib README.md   },
                  ]
    NGRAM_SIZE = 3

    attr_accessor :index, :dir, :name, :includes, :ignore, :files, :config, :monitor, :stats

    def initialize dir
      attrs = File.exist?(".zeiger.yml") ? YAML.load(File.read ".zeiger.yml") : { }
      self.dir      = File.expand_path dir
      self.name     = File.basename self.dir
      self.config   = load_config
      self.index    = Hash.new { |h, k| h[k] = [] }
      self.files    = Hash.new
      self.monitor  = Monitor.new dir, self, config
      self.stats    = Stats.new self, config
      rescan
    end

    def load_config
      conf_file = File.join dir, ".zeiger.yml"
      if File.exist?(conf_file)
        puts "reading config from #{conf_file.inspect}"
        YAML.load(File.read conf_file)
      else
        puts "config file #{conf_file.inspect} not found"
        { }
      end
    end

    def self.from_path path
      raise "no path! #{path.inspect}" if path == nil || path.strip == ''
      return INDICES[path] if INDICES[path]
      return nil if path == '/'
      return (INDICES[path] = new(path)) if ROOT_GROUPS.any? { |rg| rg.all? { |f| File.exist?(File.join path, f)       } }
      return (INDICES[path] = new(path)) if ROOT_GLOBS.any?  { |rg| rg.all? { |f| Dir.glob(File.join path, f).size > 0 } }
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
      info = files[file] = FileInfo.new(self, file, stats)

      File.read(file).split(/\n/).each_with_index { |txt, line|
        line = Line.new(info, line + 1, txt).ngrams(NGRAM_SIZE) do |trig, line|
          index[trig] << line
          info.add_ngram trig
        end
      }

      puts "#{info.summary} : re-index"
    rescue Exception => e
      puts "Not able to read #{file}"
      while e
        puts e.message
        puts e.backtrace.join("\n")
        puts
        e = e.cause
      end
    end

    def glob             pattern ; Dir.glob(File.join(dir, pattern))                                     ; end
    def rescan                   ; monitor.build_index                                                   ; end
    def get_ngram_lines   ngrams ; ngrams.map { |ngram| index[ngram] || [] }.reduce(&:&)                 ; end
    def exec_query regex, ngrams ; get_ngram_lines(ngrams).select { |line| line.matches? regex }         ; end
    def sort_by_filename   lines ; lines.sort_by { |line| [line.file.local_filename, line.line_number] } ; end
    def all_matching           q ; index.keys.select { |k| k.match q }.map { |k| index[k] }.reduce(&:|)  ; end

    def query txt
      puts "got query #{txt.inspect}"

      lines = if (txt.strip.to_s == '')
                puts "empty query, not searching!"
                []
              elsif txt.length <= NGRAM_SIZE
                all_matching Regexp.compile(Regexp.escape txt)
              else
                exec_query Regexp.compile(Regexp.escape txt), txt.ngrams(NGRAM_SIZE)
              end

      sort_by_filename(lines)
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
