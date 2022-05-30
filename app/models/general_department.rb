class GeneralDepartment < Organization
  self.table_name = 'organizations'
  default_scope { where(type: 'General Department') }
end
