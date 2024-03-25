require "./extensions/_all";
require "./Redis";
require "./RedisServer";

# Ensure that the program terminates on SIGTERM, https://github.com/crystal-lang/crystal/issues/8687
Signal::TERM.trap { exit; };

if portindex = ARGV.index("--port").to_safe
  Redis::ARGS[:port] = ARGV[portindex + 1];
end

if replicaofindex = ARGV.index("--replicaof").to_safe
  Redis::ARGS[:master_host] = ARGV[replicaofindex + 1];
  Redis::ARGS[:host_type] = "slave";
  Redis::ARGS[:master_port] = ARGV[replicaofindex + 2];
end

(RedisServer.new Redis::ARGS[:master_host], Redis::ARGS[:port].to_i).start;
