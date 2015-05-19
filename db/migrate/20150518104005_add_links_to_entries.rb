class AddLinksToEntries < ActiveRecord::Migration
  def change
    change_table :entries do |t|
      t.hstore :links
    end
  end
end
