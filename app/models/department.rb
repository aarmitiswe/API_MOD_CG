class Department < Organization
  self.table_name = 'organizations'
  default_scope { where(type: 'Department') }
end
