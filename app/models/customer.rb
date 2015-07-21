class Customer < ActiveRecord::Base

  encrypt_with_public_key :access_token,
                          :email,
                          key_pair: Rails.root.join('config','certs','keypair.pem'),
                          base64: true

  has_many :subscriptions
  has_many :reports
  belongs_to :signup

  def most_recent_report_with_counts
    reports.where("count > 0").first
  end
end
