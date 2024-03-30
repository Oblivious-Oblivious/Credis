require "socket";
require "./Commands";

class RedisSocket < TCPSocket
  include Commands;

  private def add_myself_to_replicas_if_master
    if Redis::VALUES[:host_type] == "master"
      Redis::REPLICAS << self;
    end
  end

  private def update_replicas_if_master(values)
    if Redis::VALUES[:host_type] == "master"
      Redis::REPLICAS.each do |replica|
        replica << encode_array (values.map &.to_s);
      end
    end
  end

  def receive(cmd)
    cmd[0] = cmd[0].downcase;
    case cmd[0]
    when "ping"
      self.ping;
    when "echo"
      self.echo cmd[1];
    when "info"
      if cmd[1].downcase == "replication"
        self.info_replication;
      end
    when "replconf"
      self.replconf cmd[1...];
    when "psync"
      add_myself_to_replicas_if_master;
      self.psync cmd[1], cmd[2];
    when "set"
      update_replicas_if_master cmd;
      if cmd.size == 5 && cmd[3].downcase == "px"
        self.set cmd[1], cmd[2], cmd[4].to_i;
      else
        self.set cmd[1], cmd[2];
      end
    when "get"
      self.get cmd[1];
    end
  end
end
