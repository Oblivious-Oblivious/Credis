module RedisProtocolEncoder
  def encode_simple_string(value : String)
    "+#{value}\r\n";
  end

  def encode_error(value : String)
    "-#{value}\r\n";
  end

  def encode_integer(value : String)
    ":#{value}\r\n";
  end

  def encode_bulk_string(value : String)
    "$#{value.bytesize}\r\n#{value}\r\n";
  end

  def encode_nil
    "$-1\r\n";
  end

  def encode_array(values : Array(String))
    array_header = "*#{values.size}\r\n";
    values.reduce(array_header) do |acc, val|
      acc + encode_bulk_string(val);
    end
  end
end
