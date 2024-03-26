require "./extensions/_all";
require "./Redis";
require "./RedisServer";

# Ensure that the program terminates on SIGTERM, https://github.com/crystal-lang/crystal/issues/8687
Signal::TERM.trap { exit; };

if portindex = ARGV.index("--port").to_safe
  Redis::VALUES[:port] = ARGV[portindex + 1];
end

if replicaofindex = ARGV.index("--replicaof").to_safe
  Redis::VALUES[:master_host] = ARGV[replicaofindex + 1];
  Redis::VALUES[:host_type] = "slave";
  Redis::VALUES[:master_port] = ARGV[replicaofindex + 2];
end

(RedisServer.new Redis::VALUES[:master_host], Redis::VALUES[:port].to_i).start;
