module Zeiger
  class Server
    def self.run command, *args
      dir = File.expand_path(".")
      z = Zeiger::Index.new dir

      Thread.new do
        begin
          puts "monitor thread"
          monitor = Zeiger::Monitor.new dir, z
          puts "created monitor"
          while true do
            puts "scanning..."
            monitor.build_index
            sleep 10
          end
        rescue Exception => e
          puts e.message
          puts e.backtrace
        end
      end

      puts "query thread..."

      Socket.unix_server_loop(SOCKET_NAME) { |sock, client|
        puts "query thread: server loop"
        begin
          z.query(sock.readline.strip).each { |res| sock.puts res.to_s }
        ensure
          sock.close
        end
      }
    end
  end
end
