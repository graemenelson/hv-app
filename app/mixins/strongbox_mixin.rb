module StrongboxMixin

  def decrypt(value)
    value.is_a?(Strongbox::Lock) ?
      value.decrypt(ENV['STRONGBOX_PASSWORD']) :
      value
  end

end
