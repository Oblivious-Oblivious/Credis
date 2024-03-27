require "./RedisStore";
require "./RedisProtocolEncoder";

module Commands
  include RedisProtocolEncoder;

  private def add_myself_to_replicas_if_master
    if Redis::VALUES[:host_type] == "master"
      Redis::REPLICAS << self;
    end
  end

  private def update_replicas_if_master(values)
    if Redis::VALUES[:host_type] == "master"
      Redis::REPLICAS.each do |replica|
        replica << encode_array (values.map &.to_s);
      end
    end
  end

  def ping
    self << encode_simple_string "PONG";
  end

  def echo(message)
    self << encode_simple_string message;
  end

  def info_replication
    host = Redis::VALUES[:host_type];
    master_replid = Redis::VALUES[:repl_id];
    master_repl_offset = Redis::VALUES[:repl_offset];

    self << encode_bulk_string "role:#{host}\r\nmaster_replid:#{master_replid}\r\nmaster_repl_offset:#{master_repl_offset}";
  end

  def replconf(args)
    self << encode_simple_string "OK";
  end

  def psync(id, offset)
    id = Redis::VALUES[:repl_id];
    offset = Redis::VALUES[:repl_offset];

    add_myself_to_replicas_if_master;
    self << encode_simple_string "FULLRESYNC #{id} #{offset}";
    self << encode_file Redis.create_and_delete_empty_rdb;
  end

  def set(key, value)
    update_replicas_if_master ["set", key, value];
    RedisStore.shared.set(key, value);
    self << encode_simple_string "OK";
  end

  def set(key, value, timeout)
    update_replicas_if_master ["set", key, value, timeout];
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
