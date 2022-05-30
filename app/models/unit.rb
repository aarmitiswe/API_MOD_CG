class Unit < Organization
  self.table_name = 'organizations'
  default_scope { where(type: 'Unit') }
end
