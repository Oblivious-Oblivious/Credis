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
    read_line.to_i.to_s;
  end

  private def decode_nil
    "";
  end

  private def decode_nil_array
    [""];
  end

  private def decode_bulk_string
    begin
      length = read_line.to_i;
      start = @index;
      @index += length + 2; # Skip the bulk string and trailing \r\n
      @data[start...start + length];
    rescue ex : Exception
      decode_nil;
    end
  end

  private def decode_array
    begin
      length = read_line.to_i;
      Array.new(length.to_i) { decode_without_array; };
    rescue ex : Exception
      decode_nil_array;
    end
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

  private def decode
    case current_char;
    when '*'
      decode_array;
    else
      decode_nil_array;
    end
  end

  def decode_stream
    response_objects = [] of Array(String);

    while (command = decode) != [""]
      response_objects << command;
    end

    @index = 0;
    if response_objects.empty? || response_objects[0].includes? ""
      [[""]];
    else
      response_objects;
    end
  end
end
