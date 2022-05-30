module MapperAttributes
  GENDER = %w(not_defined male female)

  def get_attribute_val attribute_name, attribute_index
    Object.const_get("MapperAttributes::#{attribute_name.upcase}")[attribute_index]
  end

  def get_attribute_index attribute_name, attribute_val
    Object.const_get("MapperAttributes::#{attribute_name.upcase}").index(attribute_val)
  end

  def mapper_birthday birthday_obj
    "#{birthday_obj[:dob_day]}-#{birthday_obj[:dob_month]}-#{birthday_obj[:dob_year]}".to_date
  end
end