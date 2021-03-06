class FixColumnLimits < ActiveRecord::Migration
  def up
    # This doesn't change anything at Rails' level, but it causes the change in
    # config/initializers/remove_default_column_limit.rb to take effect.
    change_column :entries, :content_id, :string
    change_column :entries, :title, :string
    change_column :entries, :format, :string
    change_column :entries, :base_path, :string
  end

  def down
  end
end
