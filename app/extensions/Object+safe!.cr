class Object
  def safe!
    begin
      self.not_nil!;
    rescue NilAssertionError
      exit;
    end
  end
end
