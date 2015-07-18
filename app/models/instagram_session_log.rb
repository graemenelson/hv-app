class InstagramSessionLog < ActiveRecord::Base
  belongs_to :instagram_session

  serialize :params

  def close!
    save
  end

end
