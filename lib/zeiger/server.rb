require 'yaml'

module Zeiger
  SOCKET_NAME = "/tmp/zeiger-index"

  class Server
    def run command, *args
      Thread.new do
        begin
          while true do
            indices = Zeiger::INDICES.values
            indices.each do |index|
              puts "scanning #{index.name} at #{index.dir}"
              index.rescan
            end
            sleep 10
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
          puts "querying index #{index.name}"

          case incoming[:command]
          when :search
            index.query(incoming[:search]).each { |res| sock.puts res.to_s }
          when :stats
            sock.puts index.stats.stats.to_yaml
          when :files
            index.file_list(incoming[:files]).each { |f| sock.puts f.local_filename }
          end

        ensure
          sock.close
        end
      }
    end
  end
end
