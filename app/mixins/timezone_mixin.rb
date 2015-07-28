module TimezoneMixin
  def set_timezone
    @original_timezone = Time.zone
    Time.zone = timezone
  end

  def reset_timezone
    Time.zone = @original_timezone
  end  
end
