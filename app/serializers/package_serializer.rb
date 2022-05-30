class PackageSerializer < ActiveModel::Serializer
  include HtmlWithArrayHelper

  attributes :id, :name, :description, :price, :currency, :job_postings, :db_access_days, :employer_logo, :details

  def name
    serialization_options[:ar] && object.ar_name ? object.ar_name : object.name
  end

  def description
    serialization_options[:ar] && object.ar_description ? object.ar_description : object.description
  end

  def details
    package_details = serialization_options[:ar] && object.ar_details ? object.ar_details : object.details
    convert_array_to_html_string(package_details.include?("\r\n") ? package_details.split("\r\n") : package_details.split("\n\n"))
  end
end