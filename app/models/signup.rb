class Signup < ActiveRecord::Base
  # TODO: encrypt access_token
  # TODO: encrypt email

  validates :access_token,
            :instagram_id,
            :instagram_username,
            presence: true

  validates :email, presence: true, email: true, on: :update, if: :validate_email_and_billing_info?
  validates :payment_method_nonce, presence: true, on: :update, if: :validate_email_and_billing_info?

  # Checks to see if we have captured the email
  # and billing information (payment_method_nonce).
  #
  # Enables email and billing info validation on current
  # record, then calls valid?
  #
  # If we haven't captured the necessary information, then
  # the record will have errors on the invalid fields:  email and/or
  # payment_method_nonce
  def captured_email_and_billing_info?
    enable_email_and_billing_info_validations do
      valid?
    end
  end

  private

  def enable_email_and_billing_info_validations(&block)
    @validate_email_and_billing_info = true
    result = yield
    @validate_email_and_billing_info = false
    result
  end

  def validate_email_and_billing_info?
    @validate_email_and_billing_info
  end

end
