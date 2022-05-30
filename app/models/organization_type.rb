class OrganizationType < ActiveRecord::Base
  # TYPES = %w(ExecutiveOffice Agency GeneralDepartment Department Center Section Unit)
  TYPES = ["Executive Office", "Deputy", "General Department", "Department", "Center", "Section", "Unit"]

  before_save :set_order

  def set_order
    if self.order.nil?
      self.order = TYPES.find_index(self.name) || TYPES.size
      self.order += 1
    end
  end
  
  def self.change_organization_type_serializer
    OrganizationType.find_by(name:"Deputy").update(ar_name:"الوكالة");
    OrganizationType.find_by(name:"General Department").update(ar_name:"إدارة عامة");
    OrganizationType.find_by(name:"Department").update(ar_name:"إدارة");
    OrganizationType.find_by(name:"Section").update(ar_name:"قسم");
    OrganizationType.find_by(name:"Unit").update(ar_name:"وحدة");
    OrganizationType.find_by(name:"Center").update(ar_name:"مركز");
    puts "Changed"
  end
end

