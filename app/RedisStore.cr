class RedisStore
  getter data = {} of String => String;

  private def delete_after_timeout(key, timeout)
    sleep(timeout / 1000);
    data.delete key;
  end

  def self.shared
    @@shared ||= new;
  end

  def include?(key)
    data.has_key?(key);
  end

  def get(key)
    data[key];
  end

  def set(key, value)
    data[key] = value;
  end

  def set_with_expiration(key, value, timeout)
    data[key] = value;
    spawn { delete_after_timeout key, timeout; };
  end
end
