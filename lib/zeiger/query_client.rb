module Zeiger
  class QueryClient
    def self.run command, q, *args
      Socket.unix(SOCKET_NAME) { |sock|
        sock.puts("SEARCH: #{q}")
        while !sock.eof?
          puts sock.readline
        end
      }
    end
  end
end
