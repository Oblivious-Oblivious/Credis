require "socket";
require "./Commands";

class RedisSocket < TCPSocket
  include Commands;

  def send(cmd_builder, cmds)
    cmds.each do |cmd|
      operation = cmd[0].downcase;

      if operation == "ping"
        self.ping;
      elsif operation == "echo"
        self.echo cmd[1];
      elsif operation == "set"
        self.set cmd[1], cmd[2];
      elsif operation == "get"
        self.get cmd[1];
      end
    end
  end
end
