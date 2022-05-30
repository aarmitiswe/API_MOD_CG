class Api::V1::DemoRequestsController < ApplicationController
  respond_to :json
  skip_before_action :authenticate_user
  skip_authorize_resource

  def create
    @bloovo_mailer = BloovoMailer.new
    @bloovo_mailer.send_demo_email(demo_params)

    render :json => {}
  end

  def create_ats

    @bloovo_mailer = BloovoMailer.new
    @bloovo_mailer.send_ats_demo_email(ats_demo_params)
    render :json => {}
  end

  def demo_params
    params.require(:demo).permit(:company_name,:country,:contact_person,:phone_number,:email,:reason)
  end

  def ats_demo_params
    params.require(:demo).permit(:company_name,:country, :city, :contact_person,:phone_number,:email,:reason)
  end

end