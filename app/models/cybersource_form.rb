class CybersourceForm
  include ActiveModel::Model

  # Accessors.
  attr_accessor :access_key, :profile_id, :payment_method, :transaction_uuid, :signed_field_names, :unsigned_field_names, :locale,
                :transaction_type, :reference_number, :amount, :currency, :customer_ip_address, :bill_to_forename, :bill_to_surname,
                :bill_to_email, :bill_to_phone, :bill_to_address_line1, :bill_to_address_city, :bill_to_address_state, :bill_to_address_country,
                :bill_to_address_postal_code, :signed_date_time, :signature, :merchant_defined_data1,:merchant_defined_data2, :user_id ,:card_cvn ,:ignore_cvn

  def initialize(*args)
    @access_key, @profile_id, @payment_method, @transaction_uuid,@ignore_cvn, @locale,
        @transaction_type, @reference_number, @amount, @currency, @customer_ip_address, @merchant_defined_data1,@merchant_defined_data2,@user_id, @unsigned_field_names, @bill_to_forename, @bill_to_surname,
        @bill_to_email, @bill_to_phone, @bill_to_address_line1, @bill_to_address_city, @bill_to_address_state, @bill_to_address_country,
        @bill_to_address_postal_code, @signed_field_names, @signature = args
  end

  def attrs
    attrs = Hash.new
    instance_variables.each do |var|
      str = var.to_s.gsub /^@/, ''
      if respond_to? "#{str}="
        attrs[str.to_sym] = instance_variable_get var
      end
    end
    attrs
  end

  def attrs_to_sign
    attrs = Hash.new
    signed_fields = self.signed_fields.split(/\s*,\s*/)
    signed_fields.each do |field|
      attrs[field] = instance_variable_get ('@'+field).to_sym
    end
    attrs
  end

  def signed_fields
    "access_key,profile_id,transaction_uuid,signed_field_names,unsigned_field_names,signed_date_time,locale,transaction_type,reference_number,amount,currency,payment_method,customer_ip_address,merchant_defined_data1,merchant_defined_data2"
  end

  def unsigned_data
    "device_fingerprint_id,card_type,card_number,card_expiry_date,bill_to_forename,bill_to_surname,bill_to_email,bill_to_phone,bill_to_address_line1,bill_to_address_city,bill_to_address_state,bill_to_address_country,bill_to_address_postal_code,card_cvn"
  end

  def get_expiration_month(date)
    date.split('-')[0]
  end

  def get_expiration_year(date)
    date.split('-')[1]
  end

  def get_last_4(card_number)
    card_number.split('x').last
    card_number.split('x').last
  end

  def get_bin_number(card_number)
    card_number.split('x').first
  end

  def get_card_name(card_code)
    case card_code
      when '001'
        'visa'
      when '002'
        'master'
      when '003'
        'AMEX'
      when '004'
        'Discover'
      when '004'
        'Diners'
      when '005'
        'Diners - Carte Blanche'
      when '006'
        'Carte Blanche'
      when '007'
        'JCB'
      when '014'
        'EnRoute'
      when '021'
        'JAL'
      when '024'
        'Delta'
      when '033'
        'Visa Electron'
      when '034'
        'Dankort'
      else
        card_code
    end
  end


end