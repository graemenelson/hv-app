class Signup < ActiveRecord::Base
  # TODO: encrypt access_token
  # TODO: encrypt email

  attr_accessor :allow_blank_email

  validates :access_token,
            :instagram_id,
            :instagram_username,
            presence: true

  validates :email, presence: true, email: true, on: :update, unless: :allow_blank_email?

  private

  def allow_blank_email?
    allow_blank_email
  end

end
