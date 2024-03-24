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
        if cmd.size == 5 && cmd[3] == "px"
          self.set cmd[1], cmd[2], cmd[4].to_i;
        else
          self.set cmd[1], cmd[2];
        end
      elsif operation == "get"
        self.get cmd[1];
      end
    end
  end
end
