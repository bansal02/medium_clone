class CreateStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :statuses do |t|
      t.string :username
      t.integer :requests, default: 0
      t.integer :views, default: 1
      t.date :subscription_date, default: Date.today
      t.date :last_request_date, default: Date.today
      t.timestamps
    end
  end
end
