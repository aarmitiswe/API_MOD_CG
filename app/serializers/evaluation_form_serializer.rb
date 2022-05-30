class EvaluationFormSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id, :name
  has_many :evaluation_questions

  def name
    serialization_options[:ar] && object.ar_name ? object.ar_name : object.name
  end

  # def current_user_submit
  #   EvaluationSubmitSerializer.new(object.evaluation_submits.where(job_application_id: serialization_options[:job_application_id],
  #                                                                  user_id: current_user.id).first, root: false).serializable_object(serialization_options) if serialization_options[:job_application_id] && current_user
  # end
end
