require 'yaml'

module Zeiger
  SOCKET_NAME = "/tmp/zeiger-index"

  class Server
    def run command, sleepytime=nil, *args
      sleepytime = (sleepytime || 10).to_f
      raise "sleep time must be greater than zero, got #{sleepytime.inspect}" unless sleepytime > 0.0
      puts "starting server with sleep interval of #{sleepytime} seconds"
      Thread.new do
        begin
          while true do
            indices = Zeiger::INDICES.values
            indices.each do |index|
              puts "#{Time.now} scanning #{index.name} at #{index.dir}"
              index.rescan
            end
            sleep sleepytime
          end
        rescue Exception => e
          puts e.message
          puts e.backtrace
        end
      end

      Socket.unix_server_loop(SOCKET_NAME) { |sock, client|
        begin
          length   = sock.read(4).unpack("I")[0]
          query    = sock.read(length)
          incoming = YAML.load(query)
          puts incoming.to_yaml

          index = Index.from_path incoming[:pwd]

          if index
            puts "querying index #{index.name}"

            case incoming[:command]
            when :search
              index.query(incoming[:search]).each { |res| sock.puts res.to_s }
            when :stats
              sock.puts index.stats.stats.to_yaml
            when :files
              index.file_list(incoming[:files]).each { |f| sock.puts f.local_filename }
            end

          else
            puts "no index found for path #{incoming[:pwd].inspect}"
          end

        ensure
          sock.close
        end
      }
    end
  end
end
