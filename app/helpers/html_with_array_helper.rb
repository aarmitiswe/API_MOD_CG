module HtmlWithArrayHelper
  def convert_html_list_to_array html_string
    doc = Nokogiri::HTML.parse(html_string)
    arr = []
    doc.css('li').each{ |element| arr << element.text unless element.text.blank? }
    doc.css('p').each{ |element| arr << element.text unless element.text.blank? }
    arr
  end

  def convert_array_to_html_string array
    array.map! { |line|  "<li>#{line}</li>\n"}
    "<ul>\n#{array.join("")}</ul>"
  end
end
