require "socket";

class RedisSocket
  def get_char : String?
    buffer = Bytes.new 1;
    read_bytes = read buffer;
    return nil if read_bytes == 0;
    buffer[0].chr.to_s;
  rescue IO::EOFError
    nil;
  end
end
