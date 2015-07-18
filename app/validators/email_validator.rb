class EmailValidator < ActiveModel::EachValidator
  include StrongboxMixin

  def validate_each(record, attribute, value)
    unless decrypt(value) =~ /@/
      record.errors[attribute] << (options[:message] || "does not look like an email")
    end
  end
end
