module Zeiger
  class QueryClient
    def self.run pwd, command, q, *args
      Socket.unix(SOCKET_NAME) { |sock|
        s = YAML.dump({ pwd: pwd, search: q })
        sock.write([s.bytesize].pack("I"))
        sock.write(s)

        while !sock.eof?
          puts sock.readline
        end
      }
    end
  end
end
