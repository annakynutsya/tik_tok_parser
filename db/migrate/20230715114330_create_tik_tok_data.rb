class CreateTikTokData < ActiveRecord::Migration[7.0]
  def change
    create_table :tik_tok_data do |t|
      t.string :channel_name
      t.integer :subscribers
      t.float :avg_views_per_video
      t.text :description
      t.boolean :mistletoe
      t.string :social_networks

      t.timestamps
    end
  end
end
