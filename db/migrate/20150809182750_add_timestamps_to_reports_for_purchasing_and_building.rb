class AddTimestampsToReportsForPurchasingAndBuilding < ActiveRecord::Migration
  def change
    change_table :reports do |t|
      t.timestamp :purchased_at
      t.timestamp :build_posts_finished_at
      t.timestamp :build_pdf_finished_at
    end
  end
end
