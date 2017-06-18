require 'yaml'
module Zeiger
  class Server
    def self.run command, *args
      dir   = File.expand_path(".")
      z     = Zeiger::Index.new dir
      ready = false

      Thread.new do
        begin
          monitor = Zeiger::Monitor.new dir, z
          while true do
            puts "scanning..."
            monitor.build_index
            ready = true
            sleep 10
          end
        rescue Exception => e
          puts e.message
          puts e.backtrace
        end
      end

      Socket.unix_server_loop(SOCKET_NAME) { |sock, client|
        puts "query thread: server loop"
        begin
          length   = sock.read(4).unpack("I")[0]
          query    = sock.read(length)
          incoming = YAML.load(query)
          puts incoming.to_yaml

          if incoming[:search]
            z.query(incoming[:search]).each { |res| sock.puts res.to_s }
          elsif incoming.key? :files
            z.file_list(incoming[:files]).each { |f| sock.puts f.local_filename }
          elsif incoming.key? :ready
            sock.puts ready.inspect
          end

        ensure
          sock.close
        end
      }
    end
  end
end
