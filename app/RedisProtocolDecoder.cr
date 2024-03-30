require "./RedisSocket";

class RedisProtocolDecoder
  private def current_char
    begin
      char = @socket.get_char;
      char ? char.to_s[0] : "";
    rescue
      "";
    end
  end

  private def read_line
    line = @socket.gets "\r\n";
    if line
      line.chomp "\r\n";
    else
      "";
    end
  rescue
    "";
  end

  private def decode_simple_string
    read_line;
  end

  private def decode_error
    "Error: #{read_line}";
  end

  private def decode_integer
    read_line.to_i.to_s;
  end

  private def decode_nil
    "";
  end

  private def decode_nil_array
    [""];
  end

  private def decode_bulk_string
    length = read_line.to_i;
    buffer = Bytes.new length;
    @socket.read buffer;
    @socket.read (Bytes.new 2);
    String.new buffer;
  rescue ex : Exception
    decode_nil;
  end

  private def decode_array
    length = read_line.to_i;
    Array.new(length) { decode_without_array; };
  rescue ex : Exception
    decode_nil_array;
  end

  private def decode_without_array
    case current_char
    when '+'
      decode_simple_string;
    when '-'
      decode_error;
    when ':'
      decode_integer;
    when '$'
      decode_bulk_string;
    else
      decode_nil;
    end
  end

  def initialize(@socket : RedisSocket)
  end

  def decode
    case current_char
    when '*'
      decode_array;
    else
      decode_nil_array;
    end
  end
end
