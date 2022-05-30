require 'roo'

class Organization < ActiveRecord::Base
  include Pagination

  belongs_to :organization_type

  belongs_to :parent_organization, class_name: Organization, foreign_key: :parent_organization_id

  has_many :children_organizations, class_name: Organization, source: :organization, foreign_key: :parent_organization_id, dependent: :nullify

  has_many :organization_users, dependent: :destroy
  has_many :users, through: :organization_users
  has_many :managers, -> { where("organization_users.is_manager = ? AND users.active = ?", true, true).where.not("users.role_id": Role.where(name: ['Recruiter','General Department Recruitment Officer']).pluck(:id)) }, class_name: User, foreign_key: 'user_id', through: :organization_users, source: :user

  has_many :jobs, dependent: :nullify
  has_many :job_requests, dependent: :nullify

  has_many :positions, dependent: :nullify
  has_many :requisitions, dependent: :nullify
  has_many :requisitions_active, -> {where(requisitions:  {is_deleted: false})}, foreign_key: "organization_id", class_name: "Requisition"

  has_many :evaluation_submit_requisitions, dependent: :nullify
  # has_many :all_positions, class_name: Position, source: :position, foreign_key: 'organization_id', through: :children_organizations

  # validate :validate_correct_order, on: :create
  validates_presence_of :name
  # validates_presence_of :oracle_id

  scope :order_by_alphabetical, -> {  order("name ASC") }
  scope :order_by_created_at, -> {  order("created_at DESC") }

  # is_executive_office? & is_unit?
  OrganizationType::TYPES.each { |type| define_method("is_#{type.downcase.gsub(/[\ \-]/, '_')}?") { self.organization_type.try(:name) == type } }

  def hiring_manager
    self.managers.first
  end

  def all_parent_orgnizations
    current = self
    ancestors_arr = []
    max_level = 7
    i = 1
    while current.present? && i < max_level do
      ancestors_arr << current
      # ancestors_arr << current { organization: current, organization_type: current.organization_type}
      current = current.parent_organization
      i += 1
    end
    ancestors_arr
  end

  # This function return manager with organization in the ancestor of tree!
  # This return managers without EXECUTIVE OFFICE
  def all_managers_with_organization start_level=4
    managers = []
    current = self
    while start_level != -1 && current.present? && current.organization_type.present? && start_level < current.organization_type.order
      current = current.parent_organization
    end
    deputy_manager = nil

    while current.present?
      if !["Executive Office", "ExecutiveOffice", "Deputy"].include?(current.organization_type.try(:name))
        managers << current.managers.map{|user| {organization: current, manager: user}}
      elsif current.organization_type.try(:name) == "Deputy"
        deputy_manager = current.managers.map{|user| {organization: current, manager: user}}
      end
      current = current.parent_organization
    end

    #remove duplicates and join 2d arrays into 1d
    # recruitment_manager_role = Role.find_by_name(Role::RECRUITMENT_MANAGER)
    # User.where(role_id: recruitment_manager_role.try(:id)).each{|u| managers << {organization: nil, manager: u}}
    # managers.flatten.uniq
    if !["Executive Office", "ExecutiveOffice", "Deputy"].include?(self.organization_type.try(:name))
      User.last_approver.each{|u| managers << {organization: nil, manager: u}}
    end
    managers << deputy_manager
    managers.flatten.uniq
  end

  def all_managers_with_organization_for_evaluation_submits start_level=7
    managers = []
    current = self
    # while start_level != -1 && current.present? && current.organization_type.present? && start_level < current.organization_type.order
    #   current = current.parent_organization
    # end

    while current.present?
      if !["Executive Office", "ExecutiveOffice"].include?(current.organization_type.try(:name))
        managers << current.managers.map{|user| {organization: current, manager: user}}
      end
      current = current.parent_organization
    end

    managers.flatten.uniq
  end

  def all_managers start_level=4
    managers = []
    current = self
    while start_level != -1 && current.present? && current.organization_type.present? && start_level < current.organization_type.order
      current = current.parent_organization
    end
    while current.present?
      managers << current.managers
      current = current.parent_organization
    end
    #remove duplicates and join 2d arrays into 1d
    managers.flatten.uniq
  end

  def all_children_organizations
    if self.nil?
      return
    end

    organizations = [self]
    self.children_organizations.each{|org| organizations << org.all_children_organizations }
    organizations.flatten
  end

  def all_position_ids_wrong
    current = self
    position_ids = [current.position_ids]

    while current.children_organizations.present?
      current = current.children_organizations.first
      position_ids << current.position_ids
    end

    ##self.children_organizations.each{|org| position_ids << org.all_position_ids }
    position_ids.flatten.uniq
  end

  def all_position_ids
    ids = []
    stack = [self]
    while !stack.empty? do
      org = stack.pop
      ids << org.position_ids
      org.children_organizations.each{|org| stack << org}
    end
    ids.flatten.uniq
  end

  def all_job_ids
    ids = []
    stack = [self]
    while !stack.empty? do
      org = stack.pop
      ids << org.job_ids
      org.children_organizations.each{|org| stack << org}
    end
    ids.flatten.uniq
  end

  def validate_correct_order
    if self.parent_organization.present? && self.organization_type.present? && (self.organization_type.order || 1) <= (self.parent_organization.organization_type.order || 1)
      errors.add(:organization_type, 'order not correct')
    end
  end

  def self.import_xslx_file file_path
    xlsx = Roo::Spreadsheet.open(file_path, extension: :xlsx)
    Rails.logger.info xlsx.info

    organizations_sheet = xlsx.sheet(0)

    (2..organizations_sheet.last_row).each_with_index do |row_num, index|
      OrganizationType.find_or_create_by(name: organizations_sheet.cell('C', row_num))
      parent_organization_id = organizations_sheet.cell('D', row_num)
      parent_organization_id = parent_organization_id.present? && parent_organization_id.to_i > 0 ? parent_organization_id.to_i : nil

      break if organizations_sheet.cell('A', row_num).blank? || organizations_sheet.cell('B', row_num).blank?

      organization = {
          id: organizations_sheet.cell('A', row_num),
          name: organizations_sheet.cell('B', row_num),
          organization_type_id: OrganizationType.find_by_name(organizations_sheet.cell('C', row_num)).try(:id),
          parent_organization_id: parent_organization_id,
          oracle_id: organizations_sheet.cell('A', row_num)
      }

      next if Organization.find_by_id(organization[:id]).present?

      org = Organization.new(organization)
      org.save
    end

    Rails.logger.info "========== DONE ORGANIZATIONS ==============="

    users_sheet = xlsx.sheet(1)

    Role.create_roles

    (2..users_sheet.last_row).each do |row_num|

      Role.find_or_create_by(name: users_sheet.cell('E', row_num))
      user_id = users_sheet.cell('A', row_num)

      break if users_sheet.cell('A', row_num).blank? || users_sheet.cell('B', row_num).blank?

      user_obj = {
          id: User.find_by_id(user_id).present? ? nil : user_id,
          first_name: users_sheet.cell('B', row_num),
          last_name: users_sheet.cell('C', row_num),
          email: users_sheet.cell('D', row_num).downcase,
          is_hiring_manager: users_sheet.cell('E', row_num) == 'Hiring Manager',
          role_id: Role.find_by_name(users_sheet.cell('E', row_num)).try(:id),
          password: 'Test@1234',
          password_confirmation: 'Test@1234',
          birthday: Date.today - 30.years,
          active: true,
          deleted: false,
          oracle_id: user_id
      }

      next if User.find_by_id(user_obj[:id]).present? || User.find_by_email(user_obj[:email]).present?

      user = User.new(user_obj)
      user.skip_validation
      user.skip_confirmation!
      if user.save!
        user.delay(run_at: ((index+1)*10).seconds.from_now, queue: 'sending_mails').send_reset_password_instructions

        CompanyUser.create(user_id: user.id, company_id: Company.first.id)
      end
    end

    Rails.logger.info "========== DONE USERS ==============="

    organization_users_sheet = xlsx.sheet(2)

    (2..organization_users_sheet.last_row).each do |row_num|
      break if organization_users_sheet.cell('A', row_num).blank? || organization_users_sheet.cell('B', row_num).blank?

      organization_user_obj = {
          organization_id: organization_users_sheet.cell('A', row_num),
          user_id: organization_users_sheet.cell('B', row_num),
          is_manager: organization_users_sheet.cell('C', row_num) == 'TRUE'
      }

      next if OrganizationUser.find_by(organization_id: organization_user_obj[:organization_id], user_id: organization_user_obj[:user_id]).present? ||
          User.find_by_id(organization_user_obj[:user_id]).blank? ||
          Organization.find_by_id(organization_user_obj[:organization_id]).blank?

      OrganizationUser.create(organization_user_obj)
    end

    Rails.logger.info "========== DONE ORGANIZATION USERS ==============="

    positions_sheet = xlsx.sheet(3)

    (2..positions_sheet.last_row).each do |row_num|
      break if positions_sheet.cell('A', row_num).blank? || positions_sheet.cell('B', row_num).blank?

      grade = positions_sheet.cell('E', row_num)
      Grade.find_or_create_by(name: grade) if grade.present?

      position_obj = {
          id: positions_sheet.cell('A', row_num),
          job_title: positions_sheet.cell('B', row_num),
          ar_job_title: positions_sheet.cell('C', row_num),
          employment_type: positions_sheet.cell('D', row_num),
          grade_id: Grade.find_by_name(positions_sheet.cell('E', row_num)).try(:id),
          position_status_id: PositionStatus.find_by_name(positions_sheet.cell('F', row_num)).try(:id),
          organization_id: positions_sheet.cell('H', row_num).try(:to_i),
          oracle_id: positions_sheet.cell('A', row_num)
      }

      # next if Position.find_by_id(position_obj[:id]).present?
      position = Position.find_by_id(position_obj[:id])
      if position.present?
        position.update(position_obj)
      else
        Position.create(position_obj)
      end
    end

    Rails.logger.info "========== DONE POSITIONS ==============="
  end
end
