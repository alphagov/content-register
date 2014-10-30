class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :content_id, :title, :format, null: false
      t.string :base_path

      t.timestamps
    end

    add_index :entries, :content_id, unique: true
    add_index :entries, :format
  end
end
