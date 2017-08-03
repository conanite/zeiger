module Zeiger
  class Stats
    attr_accessor :index, :group_cfg, :comment_cfg

    def initialize index, config
      @index = index
      @group_cfg = config["stats"]
      @comment_cfg = compile_comment_cfg config["comments"]
    end

    def compile_comment_cfg cfg
      (cfg || { }).each_with_object({ }) do |(file_pattern, regex_list), result|
        result[Regexp.compile(file_pattern)] = regex_list.map { |r| Regexp.compile r }
      end
    end

    def stats_group filename
      (group_cfg || []).each { |group, regexes| return group if regexes.any? { |r| filename.match r } }
      "undefined"
    end

    def comment_rules filename
      file_type = comment_cfg.keys.detect { |rxp| filename.match rxp }
      comment_cfg[file_type] || []
    end

    def stats
      index.files.values.each_with_object(Hash.new { |h,k| h[k] = 0 }) do |file, results|
        results[file.stats_group] += file.nc_nb_line_count
      end
    end
  end
end
