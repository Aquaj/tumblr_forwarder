class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :uuid
      t.string :reblog_key
      t.string :blog_uuid
      t.boolean :reblogged, default: false
      t.references :transfer

      t.timestamps
    end
  end
end
