class Object
  def to_safe
    begin
      self.not_nil!;
    rescue
      nil;
    end
  end
end
