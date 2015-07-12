class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /@/
      record.errors[attribute] << (options[:message] || "does not look like an email")
    end
  end
end
