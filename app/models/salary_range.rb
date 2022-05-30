class SalaryRange < ActiveRecord::Base

  def name
    self.salary_from < 10000 ? "#{self.salary_from}-#{self.salary_to}" : "+100000"
  end

  def name_currency_format
    self.salary_from < 10000 ? "#{self.salary_from}$-#{self.salary_to}$" : "+100000$"
  end

  def get_average_salary
    (!self.salary_from.blank? && !self.salary_to.blank?) ? (self.salary_from + self.salary_to) / 2 : 0
  end
end
