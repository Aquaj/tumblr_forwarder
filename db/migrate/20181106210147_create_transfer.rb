class CreateTransfer < ActiveRecord::Migration[5.2]
  def change
    create_table :transfers do |t|
      t.string :source_consumer_key
      t.string :source_consumer_secret
      t.string :source_token
      t.string :source_token_secret
      t.string :source_blog
      t.string :source_tag

      t.string :destination_consumer_key
      t.string :destination_consumer_secret
      t.string :destination_token
      t.string :destination_token_secret
      t.string :destination_blog
      t.string :destination_tag

      t.string :owner_email

      t.timestamps
    end
  end
end
