module Zeiger
  class FileListClient
    def self.run command, q=nil, *args
      Socket.unix(SOCKET_NAME) { |sock|
        s = YAML.dump({ files: q })
        sock.write([s.bytesize].pack("I"))
        sock.write(s)

        while !sock.eof?
          puts sock.readline
        end
      }
    end
  end
end
