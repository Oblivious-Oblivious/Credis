require "./RedisStore";

module Commands
  def ping
    self << "+PONG\r\n";
  end

  def echo(message)
    self << "+#{message}\r\n";
  end

  def set(key, value)
    RedisStore.shared.set(key, value);
    self << "+OK\r\n";
  end

  def set(key, value, timeout)
    RedisStore.shared.set_with_expiration(key, value, timeout);
    self << "+OK\r\n";
  end

  def get(key)
    if RedisStore.shared.include?(key)
      value = RedisStore.shared.get(key);
      self << "$#{value.size}\r\n#{value}\r\n";
    else
      self << "$-1\r\n";
    end
  end
end
