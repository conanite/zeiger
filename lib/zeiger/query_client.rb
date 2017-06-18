module Zeiger
  class QueryClient
    def self.run command, q, *args
      Socket.unix(SOCKET_NAME) { |sock|
        s = YAML.dump({ search: q })
        sock.write([s.bytesize].pack("I"))
        sock.write(s)

        while !sock.eof?
          puts sock.readline
        end
      }
    end
  end
end
