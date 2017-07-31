module Zeiger
  class StatsClient
    def self.run pwd, command, q=nil, *args
      Socket.unix(SOCKET_NAME) { |sock|
        s = YAML.dump({ pwd: pwd, stats: true })
        sock.write([s.bytesize].pack("I"))
        sock.write(s)

        while !sock.eof?
          puts sock.readline
        end
      }
    end
  end
end
