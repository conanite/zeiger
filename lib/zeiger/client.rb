module Zeiger
  class Client
    def self.run command, q, *args
      Socket.unix(SOCKET_NAME) { |sock|
        sock.puts(q)
        sleep(1)
        while !sock.eof?
          puts sock.readline
        end
      }
    end
  end
end
