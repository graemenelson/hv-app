class BaseService

  extend ActiveModel::Naming
  include ActiveModel::Validations

  def self.call(attrs = {})
    self.new(attrs).call
  end

  def call
    if valid?
      perform
    end
    self
  end

end
