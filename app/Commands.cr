require "./RedisStore";

module Commands
  def ping
    self << encode_simple_string "PONG";
  end

  def echo(message)
    self << encode_simple_string message;
  end

  def info_replication
    master_replid = "8371b4fb1155b71f4a04d3e1bc3e18c4a990aeeb";
    master_repl_offset = "0";

    self << encode_bulk_string "role:#{host}\r\nmaster_replid:#{master_replid}\r\nmaster_repl_offset:#{master_repl_offset}";
  end

  def replconf(args)
    self << encode_simple_string "OK";
  end

  def set(key, value)
    RedisStore.shared.set(key, value);
    self << encode_simple_string "OK";
  end

  def set(key, value, timeout)
    RedisStore.shared.set_with_expiration(key, value, timeout);
    self << encode_simple_string "OK";
  end

  def get(key)
    if RedisStore.shared.include?(key)
      self << encode_bulk_string RedisStore.shared.get(key);
    else
      self << encode_nil;
    end
  end
end
