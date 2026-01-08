# frozen_string_literal: true

class AddPostUpdatesReopened < ActiveRecord::Migration[4.2]
  def change
    add_column :messenger_settings, :post_updates_reopened, :integer, default: 0, null: false
  end
end
