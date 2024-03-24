class RedisStore
  getter data = {} of String => String;

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
end
