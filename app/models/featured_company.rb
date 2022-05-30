class FeaturedCompany < ActiveRecord::Base
  belongs_to :company

  # TODO: Remove this method
  def self.add_default_featured
    company_names = ["BEE'AH- The Sharjah Environment Company","Midas Safety Middle East","Silver Shore Trading LLC","The White Boutique",
                     "the sofitel hotel","Royal Bahrain Hospital","IFA Hotels & Resorts FZE","MIR HASHEM KHOORY LLC","LIFE Pharmacy",
                     "MEDICLINIC MIDDLE EAST","Better Homes","ZAFCO FZCO","Allsopp and Allsopp Real Estate","deVere-Group",
                     "Propertyfinder Group","Dubai Silicon Oasis Authority"]

    FeaturedCompany.create(Company.where(name: company_names).map{|c| {company_id: c.id}})
  end
end
