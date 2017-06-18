module Zeiger
  class Monitor
    attr_accessor :dir, :index, :stat, :includes, :ignore

    def initialize dir, index
      @dir, @index, @stat = dir, index, Hash.new
      attrs = load_config
      @includes = attrs["search"] || %w{ app/**/* bin/**/* config/**/* lib/**/* spec/**/* test/**/* }
      @ignore   = attrs["ignore"] || %w{ .gz$ .png$ .jpg$ .pdf$ }
    end

    def load_config
      conf_file = File.join dir, ".zeiger.yml"
      if File.exist?(conf_file)
        puts "reading config from #{conf_file.inspect}"
        YAML.load(File.read conf_file)
      else
        { }
      end
    end

    def ignore? filename
      ignore.any? { |ig| filename.match ig }
    end

    def uptodate? filename, mtime
      stat.include?(filename) && stat[filename] == mtime
    end

    def build_index
      started = Time.now
      files = Set.new
      includes.each do |inc|
        Dir.glob(File.join(dir, inc)).sort.each do |file|
          if File.file?(file) && !ignore?(file)
            files << file
            mtime = File.stat(file).mtime
            if !uptodate?(file, mtime)
              puts "re-indexing #{file}"
              index.remove_from_index file
              index.add_to_index file
              stat[file] = mtime
            end
          end
        end
      end
      (Set.new(stat.keys) - files).each { |f| index.remove_from_index f }
      finished = Time.now
      puts "ngrams       : #{index.index.length}"
      puts "files        : #{index.files.length}"
      puts "#build_index : #{(finished - started)} sec"
    end
  end
end
