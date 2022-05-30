json.array!(@event_visitors) do |api_v1_event_visitor|
  json.extract! api_v1_event_visitor, :id, :name, :company, :position, :department, :mobile_phone, :email
end
