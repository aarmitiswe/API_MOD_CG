class EmailTemplate < ActiveRecord::Base
  validates_uniqueness_of :name

  def get_page_url
    doc = Nokogiri::HTML.parse(self.body)
    doc.xpath('//a').map { |link| link['href'] }
  end
end
