class Api::V1::CompanySubscriptionsController < ApplicationController
  skip_before_action :authenticate_user

  # POST /api/v1/company_subscriptions/set_activation_code
  # {company_subscription: {activation_code: "As"}}
  def set_activation_code
    @company_subscription = CompanySubscription.first
    if @company_subscription.update(company_subscription_params)
      render json: @company_subscription
    else
      render json: @company_subscription.errors, status: :unprocessable_entity
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def company_subscription_params
      params.require(:company_subscription).permit(:activation_code).merge!({activated_at: Date.today, expires_at: Date.today+1.year})
    end
end
