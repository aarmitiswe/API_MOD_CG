class EvaluationQuestionSerializer < ActiveModel::Serializer
  attributes :id, :name, :description

  def name
    serialization_options[:ar] && object.ar_name ? object.ar_name : object.name
  end

  def description
    serialization_options[:ar] && object.ar_description ? object.ar_description : object.description
  end
end
