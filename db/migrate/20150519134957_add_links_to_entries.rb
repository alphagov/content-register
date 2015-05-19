class AddLinksToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :links, :text
  end
end
