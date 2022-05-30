class PackageBroadcastSerializer < ActiveModel::Serializer
  attributes :id, :num_credits, :price, :currency, :description
end
