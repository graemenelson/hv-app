class Signup < ActiveRecord::Base
  # TODO: encrypt access_token
  # TODO: encrypt email

  attr_accessor :allow_blank_email,
                :allow_blank_payment_method_nonce

  validates :access_token,
            :instagram_id,
            :instagram_username,
            presence: true

  validates :email, presence: true, email: true, on: :update, unless: :allow_blank_email?

  # We ask the customer to agree to the terms of service when
  # collecting their payment.
  validates :payment_method_nonce, presence: true, on: :update, unless: :allow_blank_payment_method_nonce?
  validates :terms_of_service, presence: true, acceptance: true, on: :update, unless: :allow_blank_payment_method_nonce?

  def completed!
    return false if completed?

    update_attribute(:completed_at, Time.now.utc)
  end

  def completed?
    return false unless completed_at
    completed_at <= Time.zone.now
  end

  private

  def allow_blank_email?
    allow_blank_email
  end

  def allow_blank_payment_method_nonce?
    allow_blank_payment_method_nonce
  end

end
