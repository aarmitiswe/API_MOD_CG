module DateHelper
  def subtract_to_years_months start_date, end_date
    # return nil if start_date.nil?
    end_date ||= Date.today
    start_date ||= Date.today
    subtract = end_date - start_date
    years = subtract.to_i / 365
    months = ((subtract - (years * 365)) / 30).round
    if months == 12
      years += 1
      months = 0
    end

    if years > 0 && months > 0
      "#{years} #{years == 1 ? 'Year':'Years' } #{months} #{months == 1 ? 'Month':'Months' }"
    elsif months > 0
      "#{months} #{months == 1 ? 'Month':'Months' }"
    else
      "#{years} #{years == 1 ? 'Year':'Years' }"
    end
  end

  def get_month_year start_date, end_date
    return "" if start_date.nil?
    end_date ? "#{start_date.strftime('%b %y')}-#{end_date.strftime('%b %y')}" : "#{start_date.strftime('%b %y')}-Present"
  end

  def remove_unwanted_words string
    bad_words = ["less than", "about", "over", "almost"]

    bad_words.each do |bad|
      string.gsub!(bad + " ", '')
    end

    return string
  end
end
