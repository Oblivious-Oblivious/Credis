require "socket";
require "./Commands";

class RedisSocket < TCPSocket
  include Commands;

  def send(cmd_builder, cmds)
    cmds.each do |cmd|
      if cmd[0] == "ping"
        self.ping;
      elsif cmd[0] == "echo"
        self.echo cmd[1];
      end
    end
  end
end
