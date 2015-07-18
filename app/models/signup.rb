class Signup < ActiveRecord::Base

  # TODO: encrypt email

  encrypt_with_public_key :access_token,
      key_pair: Rails.root.join('config','certs','keypair.pem'),
      base64: true

  attr_accessor :allow_blank_email,
                :allow_blank_payment_method_nonce

  belongs_to :plan

  validates :access_token,
            :instagram_id,
            :instagram_username,
            presence: true

  validates :email, presence: true, email: true, on: :update, unless: :allow_blank_email?
  validates :payment_method_nonce, presence: true, on: :update, unless: :allow_blank_payment_method_nonce?

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
