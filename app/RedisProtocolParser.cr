alias RedisValue = String | Int32 | Nil
alias RedisObject = RedisValue | Array(RedisObject)

class RedisProtocolParser
  def initialize(@data : String)
    @index = 0;
  end

  private def current_char
    char = @data[@index]?;
    @index += 1 if char;
    char;
  end

  private def read_line
    start = @index;
    @index = @data.index("\r\n", start) || @data.size;
    line = @data[start...@index];
    @index += 2; # Skip \r\n
    line;
  end

  private def decode_simple_string
    read_line;
  end

  private def decode_error
    "Error: #{read_line}";
  end

  private def decode_integer
    read_line.to_i;
  end

  private def decode_nil
    nil;
  end

  private def decode_bulk_string
    length = read_line.to_i;
    if length == -1
      nil;
    else
      start = @index;
      @index += length + 2; # Skip the bulk string and trailing \r\n
      @data[start...start + length];
    end
  end

  private def decode_array
    length = read_line.to_i;
    if length == -1
      nil
    else
      Array.new(length) { decode; };
    end
  end

  def decode : RedisObject
    case current_char
    when '+'
      decode_simple_string;
    when '-'
      decode_error;
    when ':'
      decode_integer;
    when '$'
      decode_bulk_string;
    when '*'
      decode_array;
    else
      decode_nil;
    end
  end

  def decode_stream
    response_objects = [] of RedisObject;

    while command = decode
      response_objects << command;
    end

    @index = 0;
    response_objects;
  end
end
