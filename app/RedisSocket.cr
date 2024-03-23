require "socket";
require "./Commands";

class RedisSocket < TCPSocket
  include Commands;

  def send(message)
    if message == "ping"
      self.ping;
    end
  end
end
