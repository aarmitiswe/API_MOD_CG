class AddArNameToCompanyClassification < ActiveRecord::Migration
  def change
    add_column :company_classifications, :ar_name, :string
  end
end
