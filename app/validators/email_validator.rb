class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # if we are dealing with an encrypted value make sure
    # we decrypt it before checking to see if it's a valid
    # email.
    value = value.is_a?(Strongbox::Lock) ?
              value.decrypt(ENV['ACCESS_TOKEN_PASSWORD']) :
              value
    unless value =~ /@/
      record.errors[attribute] << (options[:message] || "does not look like an email")
    end
  end
end
