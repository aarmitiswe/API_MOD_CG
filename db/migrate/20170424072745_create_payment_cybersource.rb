class CreatePaymentCybersource < ActiveRecord::Migration
  def change
    create_table :payment_cybersource_credit_cards do |t|
      t.string :payment_token
      t.string :card_type
      t.string :expiration_month
      t.string :expiration_year
      t.string :last_4
      t.string :decision
      t.string :auth_code
      t.string :auth_amount
      t.datetime :auth_time
      t.string :reason_code
      t.string :auth_trans_ref_no
      t.string :bill_trans_ref_no

      #info Payer Authentication data

      t.string :pa_reason_code
      t.string :pa_enroll_veres_enrolled
      t.text :pa_proof_xml
      t.string :pa_reason_code
      t.string :pa_enroll_e_commerce_indicator

      #Request Data
      t.string :req_reference_number
      t.string :req_transaction_uuid
      t.string :req_profile_id

      #Cybersource transaction id
      t.string :transaction_id

      t.datetime :expires_at
      t.timestamps
    end
  end
end
