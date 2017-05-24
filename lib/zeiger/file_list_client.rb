module Zeiger
  class FileListClient
    def self.run command, q=nil, *args
      Socket.unix(SOCKET_NAME) { |sock|
        sock.puts("FILES: #{q}")
        while !sock.eof?
          puts sock.readline
        end
      }
    end
  end
end
