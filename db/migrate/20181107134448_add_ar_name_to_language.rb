class AddArNameToLanguage < ActiveRecord::Migration
  def change
    add_column :languages, :ar_name, :string
  end
end
