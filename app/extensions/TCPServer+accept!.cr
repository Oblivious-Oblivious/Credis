require "socket";

class TCPServer
  def accept!
    begin
      self.accept?.not_nil!;
    rescue NilAssertionError
      exit;
    end
  end
end
