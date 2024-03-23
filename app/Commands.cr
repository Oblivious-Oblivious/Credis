module Commands
  def ping
    self << "+PONG\r\n";
  end
end
