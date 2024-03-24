require "./extensions/_all";
require "./RedisServer";

# Ensure that the program terminates on SIGTERM, https://github.com/crystal-lang/crystal/issues/8687
Signal::TERM.trap { exit; };

(RedisServer.new "0.0.0.0", 6379).start;
