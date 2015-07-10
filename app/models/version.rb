module Version

  def self.current
    @version ||= `git rev-parse HEAD`.chomp
  end

end
