module Commands
  def ping
    self << "+PONG\r\n";
  end

  def echo(message)
    self << "+#{message}\r\n";
  end
end
