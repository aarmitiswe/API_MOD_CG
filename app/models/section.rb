class Section < Organization
  self.table_name = 'organizations'
  default_scope { where(type: 'Section') }
end
