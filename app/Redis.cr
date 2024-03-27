require "./RedisSocket";

module Redis
  VALUES = {
    :port => "6379",
    :master_host => "0.0.0.0",
    :master_port => "6380",
    :host_type => "master",

    :repl_id => "8371b4fb1155b71f4a04d3e1bc3e18c4a990aeeb",
    :repl_offset => "0",
  };

  REPLICAS = [] of RedisSocket;

  VERSION = "0.0.1";

  def self.create_and_delete_empty_rdb
    magic_string = "REDIS";
    version = "0009";
    filename = "#{Random.new.hex(32)}.rdb";

    File.open filename, "w" do |file|
      file.write "#{magic_string}#{version}".to_slice;
      file.write Bytes[0xFF];
    end

    file_content = File.read filename;

    if File.exists? filename
      File.delete filename;
    end

    file_content;
  end
end
