class AddLikesCountToPlaylists < ActiveRecord::Migration[7.2]
  def change
    add_column :playlists, :likes_count, :integer
  end
end