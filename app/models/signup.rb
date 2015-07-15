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
  validates :payment_method_nonce, presence: true, on: :update, unless: :allow_blank_payment_method_nonce?

  private

  def allow_blank_email?
    allow_blank_email
  end

  def allow_blank_payment_method_nonce?
    allow_blank_payment_method_nonce
  end

end
