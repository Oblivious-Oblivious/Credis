require "socket";
require "../RedisSocket";

class RedisServer < TCPServer
  private def accept
    if client_fd = system_accept
      socket = RedisSocket.new fd: client_fd, family: family, type: type, protocol: protocol;
      socket.sync = sync?;
      socket;
    end
  end
end
