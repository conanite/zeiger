module Zeiger
  class Client
    def send data
      Socket.unix(SOCKET_NAME) { |sock|
        s = YAML.dump(data)
        sock.write([s.bytesize].pack("I"))
        sock.write(s)

        while !sock.eof?
          puts sock.readline
        end
      }
    end
  end
end
