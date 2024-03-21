require "socket";

class Commands
  getter :client;

  def initialize(@client : TCPSocket) end

  def ping
    client << "+PONG\r\n";
  end
end
