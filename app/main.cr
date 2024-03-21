require "socket";

# Ensure that the program terminates on SIGTERM, https://github.com/crystal-lang/crystal/issues/8687
Signal::TERM.trap { exit; };

class YourRedisServer
  def start
    puts "Logs from your program will appear here!";

    server = TCPServer.new "0.0.0.0", 6379;
    client = server.accept?;
  end
end

YourRedisServer.new.start;
