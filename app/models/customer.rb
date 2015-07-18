class Customer < ActiveRecord::Base

  encrypt_with_public_key :access_token,
                          key_pair: Rails.root.join('config','certs','keypair.pem'),
                          base64: true

  has_many :subscriptions
  belongs_to :signup
end
