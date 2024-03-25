require "./RedisStore";

module Commands
  def ping
    self << encode_simple_string "PONG";
  end

  def echo(message)
    self << encode_simple_string message;
  end

  def info_replication
    host = Redis::ARGS[:host_type];
    self << "$#{5+host.size}\r\nrole:#{host}\r\n";
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
