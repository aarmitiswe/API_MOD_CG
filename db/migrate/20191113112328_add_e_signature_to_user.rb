class AddESignatureToUser < ActiveRecord::Migration
  def change
    add_attachment :users, :document_e_signature
  end
end
