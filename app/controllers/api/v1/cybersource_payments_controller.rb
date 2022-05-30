class Api::V1::CybersourcePaymentsController < ApplicationController
  respond_to :json

  # before_filter :parse_json , only: [:create]
  before_filter :set_package , only: [:create]

  def parse_json
    @package = Package.find(params[:package_id])
  end

  def create
    credit_card = ActiveMerchant::Billing::CreditCard.new(credit_card_params)

    response = CybersourcePayment.send_payment_request(@current_user, credit_card, @package)

    if response.success?
      subscription = CybersourcePayment.subscribe_package @current_user, @package

      render json: { subscription: subscription,
                     package: @package,
                     cybersource_message:  response.message,
                     cybersource_status: response.params['reasonCode'] }

    else
      render json: { error: response.message, cybersource_status: Cybersourcery::ReasonCodeChecker::run(response.params['faultcode']) }, status: :unprocessable_entity
    end
  end

  def create_old
    @country = Country.find(params["cyber_source"]["country_id"])
    gateway = ActiveMerchant::Billing::CyberSourceGateway.new(:login => Rails.application.secrets[:cybersource_profile_id],
                                                              :password => Rails.application.secrets[:cybersource_sop_key],
                                                              :test => !Rails.env.production?)


    credit_card = ActiveMerchant::Billing::CreditCard.new(
        :first_name         => params["cyber_source"][:first_name],
        :last_name          => params["cyber_source"][:last_name],
        #:email              => @current_user.email,
        :number             => params["cyber_source"][:card_number],
        :month              => params["cyber_source"][:month],
        :year               => params["cyber_source"][:year],
        :verification_value => params["cyber_source"][:cvn]
    )

    response = gateway.purchase( @package.price * 100, credit_card,
                                {:user_id => @current_user.id,
                                 :email=>@current_company.owner.email,
                                 :currency => "USD",
                                 :decision_manager_enabled => "false"}
    )
    cybersource_message = response.message
    cybersource_status = response.params['reasonCode']

    if response.success?
      subscription = CompanySubscription.create(:company_id=>@current_company.id,
      :package_id=>@package.id,:active=>true,:job_posts_bank=> @package.job_postings,:expires_at=>DateTime.now + @package.db_access_days.days)

      #send payment notification
      @bloovo_mailer = BloovoMailer.new
      @bloovo_mailer.send_payment_successfull_employer(@current_company,subscription)

      render :json => { :subscription => subscription , :package => @package }

    else
      render :json => {"error" => Cybersourcery::ReasonCodeChecker::run(cybersource_status)}, status: 422
    end

  end

  private
    def set_package
      @package = @current_user.is_employer? ? Package.find_by_id(params[:package_id]) : PackageBroadcast.find_by_id(params[:package_id])
    end

    def credit_card_params
      params["cyber_source"].permit(:first_name, :last_name, :number, :month, :year, :verification_value)
    end

    def cybersource_permited_params
      params.permit(:payment_token,:card_type,:expiration_month,:expiration_year, :last_4, :decision,
                                :auth_code, :auth_amount,:auth_time, :reason_code, :auth_trans_ref_no, :bill_trans_ref_no,
                                :pa_reason_code,:pa_enroll_veres_enrolled,:pa_proof_xml,:pa_enroll_e_commerce_indicator,
                                :req_reference_number,:req_transaction_uuid,:req_profile_id,:transaction_id,:issuing_bank,:score_rmsg,:score_score_result,:req_customer_ip_address)

    end

end