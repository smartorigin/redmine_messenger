# frozen_string_literal: true

# This migration should remove dependencies on other closed sources AlphaNodes modules (Contacts, DB, and Passwords)
class RemoveAlphaNodesPrivateMods < ActiveRecord::Migration[4.2]
  def change
    change_table :messenger_settings, bulk: true do |_t|
      remove_column :messenger_settings, :post_private_contacts, :integer, default: 0, null: false if column_exists? :messenger_settings,
                                                                                                                     :post_private_contacts
      remove_column :messenger_settings, :post_private_db, :integer, default: 0, null: false if column_exists? :messenger_settings,
                                                                                                               :post_private_db
      remove_column :messenger_settings, :post_db, :integer, default: 0, null: false if column_exists? :messenger_settings, :post_db
      remove_column :messenger_settings, :post_db_updates, :integer, default: 0, null: false if column_exists? :messenger_settings,
                                                                                                               :post_db_updates
      remove_column :messenger_settings, :post_contact, :integer, default: 0, null: false if column_exists? :messenger_settings,
                                                                                                            :post_contact
      remove_column :messenger_settings, :post_contact_updates, :integer, default: 0, null: false if column_exists? :messenger_settings,
                                                                                                                    :post_contact_updates
      remove_column :messenger_settings, :post_password, :integer, default: 0, null: false if column_exists? :messenger_settings,
                                                                                                             :post_password
      remove_column :messenger_settings, :post_password_updates, :integer, default: 0, null: false if column_exists? :messenger_settings,
                                                                                                                     :post_password_updates
    end
  end
end
