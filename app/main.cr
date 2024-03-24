require "./extensions/_all";
require "./RedisServer";

# Ensure that the program terminates on SIGTERM, https://github.com/crystal-lang/crystal/issues/8687
Signal::TERM.trap { exit; };

def handle_port_number(port_str)
  port_str.to_i;
end

if ARGV.size < 2
  (RedisServer.new "0.0.0.0", 6379).start;
else
  port = handle_port_number ARGV[1];
  (RedisServer.new "0.0.0.0", port).start;
end
