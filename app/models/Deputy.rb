class Deputy < Organization
  self.table_name = 'organizations'
  default_scope { where(type: 'Deputy') }
end