module StrongParametersMixin

  def strong_parameters(parameters)
    ActionController::Parameters.new(parameters)
  end

end
