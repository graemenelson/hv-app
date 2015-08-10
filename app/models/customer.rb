class Customer < ActiveRecord::Base

  encrypt_with_public_key :access_token,
                          :email,
                          key_pair: Rails.root.join('config','certs','keypair.pem'),
                          base64: true

  has_many :subscriptions
  has_many :reports
  has_many :payments
  belongs_to :signup

  def most_recent_report_with_counts
    reports.where("count > 0").first
  end

  def current_subscription
    subscriptions.where(["start_date <= :now and :now < end_date", { now: Time.zone.now.to_date }])
                 .order(created_at: :desc)
                 .first
  end

end
