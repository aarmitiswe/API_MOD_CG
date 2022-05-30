require 'active_support/concern'
require 'notifier'

module SendInvitation
  extend ActiveSupport::Concern

  included do
    # TODO: Active Mandrill before Production
    # MANDRILL = Mandrill::API.new Rails.application.secrets['mandrill_key']
    TEMPLATES = {

        "reminder_call_interview_employer" => {name_in_db: "Join Online Interview As Employer", subject: "Interview Reminder | Your online job interview with %{JobseekerFullName} is due in %{DiffTime}"},
        "reminder_physical_interview_employer" => {name_in_db: "Join Physical Interview As Employer", subject: "Interview Reminder | Your online job interview with %{CompanyName} is due in %{DiffTime}"},
        "accept_interview_employer" => {name_in_db: "The Interview is accepted", subject: "%{JobseekerFullName} has accepted the interview invite"},
        "reject_interview" => {name_in_db: "The Interview is declined", subject: "%{JobseekerFullName} has declined the interview invite"},
        "reject_in_gp" => {name_in_db: "Reject in Graduate Program", subject: "Review of your NEOM GrOW Program application"},
        "approve_one" => {name_in_db: "Approve One", subject: "FIRST APPROVAL ON JOB POSTING REQUEST"},
        "approve_two" => {name_in_db: "Approve Two", subject: "SECOND APPROVAL ON JOB POSTING REQUEST"},
        "approve_three" => {name_in_db: "Approve Three", subject: "THIRD APPROVAL ON JOB POSTING REQUEST"},
        "approve_four" => {name_in_db: "Approve Four", subject: "FORTH APPROVAL ON JOB POSTING REQUEST"},
        "final_approve" => {name_in_db: "Approve Final", subject: "APPROVAL FOR PUBLISHING A JOB"},
        "publish_job_recruiter" => {name_in_db: "Publish Job Recruiter", subject: "REQUEST TO PUBLISH"},
        "final_approve_recruiter" => {name_in_db: "Approve Final Recruiter", subject: "APPROVAL FOR PUBLISHING A JOB"},
        "reject_job_request" => {name_in_db: "Reject Job Request", subject: "REJECTION ON JOB POSTING REQUEST"},
        "deleted_job" => {name_in_db: "Job Deleted", subject: "A USER HAS DELETED A JOB"},
        "expired_job" => {name_in_db: "Job Expired", subject: "%{JobTitle} HAS EXPIRED"},
        "new_user" => {name_in_db: "New User Created", subject: "تم إضافتكم كمستخدم جديد"},
        "share_job" => {name_in_db: "Share Job", subject: "SHARE JOB"},
        "notify_hiring_manager" => {name_in_db: "Notify Hiring Manager", subject: "Job Requisition Submitted"},
        "cancel_job_approver" => {name_in_db: "Cancel Job Approver", subject: "Job Organization Has been Changed"},
        "ask_jobseeker_for_documents" => {name_in_db: "Ask Jobseeker To Add Additional Documents", subject: "Request for Additional Documents"},
        "ask_employer_to_approve_documents" => {name_in_db: "Ask Employer To Approve Jobseeker Documents", subject: "Ask Employer To Approve Jobseeker Documents"},
        "reject_jobseeker_documents" => {name_in_db: "Reject Jobseeker Documents", subject: "Your Doucments Rejected by Employer"},
        "accept_offer_approver_one" => {name_in_db: "accept offer approver one", subject: "FIRST APPROVAL ON Offer Letter REQUEST"},
        "accept_offer_approver_two" => {name_in_db: "accept offer approver two", subject: "SECOND APPROVAL ON Offer Letter REQUEST"},
        "accept_offer_approver_three" => {name_in_db: "accept offer approver three", subject: "THIRD APPROVAL ON Offer Letter REQUEST"},
        "accept_offer_approver_four" => {name_in_db: "accept offer approver four", subject: "FORTH APPROVAL ON Offer Letter REQUEST"},
        "accept_offer_approver_final" => {name_in_db: "accept offer approver final", subject: "FINAL APPROVAL ON Offer Letter REQUEST"},
        "reject_offer_approvers" => {name_in_db: "reject offer approvers", subject: "Reject Offer Letter"},
        "accept_offer_jobseeker" => {name_in_db: "Jobseeker accept offer letter", subject: "Accept Offer Letter"},
        "reject_offer_jobseeker" => {name_in_db: "Jobseeker reject offer letter", subject: "Reject Offer Letter"},
        "send_offer_jobseeker" => {name_in_db: "Employer send offer to jobseeker", subject: "Send Offer Letter"},
        "join_event" => {name_in_db: "Join Event", subject: "You have successfully registered for “%{CareerFairName}” for “#{Rails.application.secrets[:ATS_NAME]["original_name"]}”"},

        ##############
        # "notify_hiring_manager_shared_profiles" => {name_in_db: "recruiter share candidate to hiring mananger", subject: "Share Candidate Profiles"},
        "ask_approval" => {name_in_db: "Ask Approval", subject: "طلب موافقة على نشر وظيفة جديدة"},
        "requisition_approval" => {name_in_db: "Requisition Approval", subject: "تمت الموافقة على طلب وظيفة"},
        "requisition_approval_for_creator" => {name_in_db: "Upload suggested candidate by hiring manager", subject: "تمت الموافقة على طلب وظيفة – الرجاء إضافة مرشحين"},
        "requisition_approval_for_recruiter" => {name_in_db: "Upload suggested candidate by recruiter", subject: "تمت الموافقة على طلب وظيفة – الرجاء إضافة مرشحين"},
        "requisition_full_approved_inform_hiring_manager" => {name_in_db: "Job Requisition inform hiring manager", subject: "الموافقة على طلب الوظيفة"},
        "requisition_rejection" => {name_in_db: "Requisition Rejection", subject: "تم رفض طلب وظيفة"},
        "reject_requisition_to_approves" => {name_in_db: "Reject Job Requisition To Approves", subject: "Job Requisition has been rejected"},

        "upload_candidate_by_hiring_manager" => {name_in_db: "recruiter share candidate to hiring mananger", subject: "تم ترشيح بعض المرشحين لوظيفة"},
        "reminder_shared_candidate" => {name_in_db: "reminder shared candidate to hiring manager", subject: "تم ترشيح بعض المرشحين لوظيفة"},
        "suggest_interviews" => {name_in_db: "hiring manager will get a new screen to suggest 3 interview dates by selecting date", subject: "موافقة على طلب توظيف – استعراض مواعيد المقابلة"},

        "move_candidate_by_hiring_manager" => {name_in_db: "Move candidate by hiring mananger", subject: ""},
        "interview_details" => {name_in_db: "Interview Details", subject: "تم تحديد موعد مقابلة شخصية لمرشح"},
        "interview_reminder" => {name_in_db: "interview reminder", subject: "تذكير بموعد مقابلة شخصية لمرشح"},
        "interview_finished" => {name_in_db: "interview finished", subject: "طلب تعبئة نموذج تقييم مقابلة مرشح"},
        "review_evaluation_form" => {name_in_db: "reminder review evaluation", subject: "طلب مراجعة نماذج تقييم مرشح "},

        "remider_not_fill_evaluation" => {name_in_db: "reminder not fill evaluation", subject: ""},
        "ask_to_security_clearence" => {name_in_db: "ask to submit security clearance letter to security officer", subject: "طلب متابعة ملف مرشح لإصدار تقرير التزكية المنية"},
        "security_clearence_response" => {name_in_db: "security clearance officer uploads security clearance letter report to Recruiter officer", subject: "طلب استعراض تقرير التزكية الأمنية واتخاذ الإجراء اللازم"},
        "remider_review_evaluation" => {name_in_db: "reminder review evaluation", subject: ""},
        "move_candidate_assesment" => {name_in_db: "move candidate assessment", subject: ""},
        "reset_password" => {name_in_db: "reset password", subject: "طلب تغير كلمة المرور"},
        "send_offer_request" => {name_in_db: "send offer request", subject: "ارسال طلب موافقه لعرض العمل"},
        "send_offer_request_level_1" => {name_in_db: "Asking Recruitment Manager to Approve Salary Analysis", subject: "طلب اعتماد تحليل الراتب للمرشح"},
        "send_offer_request_level_2" => {name_in_db: "Asking General Manager of HR to Approve Salary Analysis", subject: "طلب اعتماد تحليل الراتب للمرشح"},
        "send_offer_request_level_3" => {name_in_db: "Asking Chief Personnel to Approve Salary Analysis", subject: "طلب اعتماد تحليل الراتب للمرشح"},
        "send_offer_request_level_4" => {name_in_db: "Asking Deputy Minister to Approve Salary Analysis", subject: "طلب اعتماد تحليل الراتب للمرشح"},
        "send_offer_request_level_new_1" => {name_in_db: "Asking Sourcing Team Manager to Approve Salary Analysis", subject: "طلب اعتماد تحليل الراتب للمرشح"},
        "send_offer_request_level_new_2" => {name_in_db: "Asking New Recruitment Manager of HR to Approve Salary Analysis", subject: "طلب اعتماد تحليل الراتب للمرشح"},
        "send_offer_request_level_new_3" => {name_in_db: "Asking New Hiring Manager to Approve Salary Analysis", subject: "طلب اعتماد تحليل الراتب للمرشح"},
        "send_offer_request_level_new_4" => {name_in_db: "Asking Executive Office to Approve Salary Analysis", subject: "طلب اعتماد تحليل الراتب للمرشح"},
        "approved_offer_letter" => {name_in_db: "Approving Job Offer Analysis", subject: "تم اعتماد تحليل الراتب للمرشح"},
        "rejected_offer_letter" => {name_in_db: "Rejecting Job Offer Analysis", subject: "تم رفض تحليل الراتب للمرشح"},


        "complete_security_clearance" => {name_in_db: "Security Clearance Completed", subject: 'إكتمال التزكية الأمنية للمرشح'},
        "reject_security_clearance" => {name_in_db: "Security Clearance Rejected", subject: 'رفض التزكية الأمنية للمرشحح'},
        "suggest_interview_assessment" => {name_in_db: "Assessor Coordinator Suggest Interview", subject: 'أقتراح أوقات لمقابلة '},

        "send_english_assessment" => {name_in_db: "Send To English Assessor", subject: 'إنتقال المرشح لمرحلة التقييم'},

        "send_suggested_interview_assessment" => {name_in_db: "View Interview Suggestion By Recruiters", subject: 'أستعراض مواعيد المقابلة المقترحة'},
        "select_interview_assessment" => {name_in_db: "Interview Assessment Evaluation Form Filling", subject: 'مقابلة شخصية لوظيفة'},
        "result_interview_assessment" => {name_in_db: "Evaluation Report Result Sent to Recruitment Manager", subject: 'مقابلة شخصية لوظيفة'},
        "create_assessment" => {name_in_db: "Evaluating Request Candidate Via QEC Assessment", subject: 'مركز تقييم الكفاءات - تقييم وظيفي للمرشح'},
        "result_assessment" => {name_in_db: "Send QEC Result to Recruiters", subject: 'نتيجة التقييم في مركز تقييم الكفاءات للمرشح'},
        "move_to_job_offer" => {name_in_db: "Moving Candidate to Job Offer Stage", subject: 'إنتقال المرشح لمرحلة العرض الوظيفي'},
        "move_to_onboarding" => {name_in_db: "Move Candidate to Onboarding Stage", subject: 'الموافقة على العرض الوظيفي والانتقال لمرحلة ما بعد التعيين'},
        "move_internal_to_onboarding" => {name_in_db: "Move Internal Candidate to Onboarding Stage", subject: 'الانتقال الى مرحلة ما بعد التعيين'},
        "reject_offer_request" => {name_in_db: "Candidate Reject Offer Letter", subject: 'تم رفض العرض الوظيفي من قبل المرشح'},
        "negotiate_offer_request" => {name_in_db: "Negotiate Offer Letter with Candidate", subject: ' المفاوضة على العرض الوظيفي مع المرشح'},
        "prepare_stc_contract" => {name_in_db: "Prepare Official STCS Employment Contract", subject: 'طلب إعداد عقد التوظيف من قبل (STCS)'},
        "notify_joining_date" => {name_in_db: "Send Email to Relevant Departments to Prepare New Joiner", subject: ' إعلام بتاريخ مباشرة الموظف '},
        "notify_joining_date_pre_joining" => {name_in_db: "move candidate to prejoin", subject: ' الموظف سوف يباشر علي وظيفة '},
        "upload_onboard_document" => {name_in_db: "Send Email to Upload Documents New Joiner", subject: ' برجاء رفع ملفات الموظف '},
        "ask_approve_onboarding_manager" => {name_in_db: "Approve Joining Form by Onboarding Manager", subject: ' اعتماد نموذج المباشرة للموظف '},
        "notify_approve_joining_form_recruitment_manager" => {name_in_db: "Approve Joining Form by Recruitment Manager", subject: ' اعتماد نموذج المباشرة للموظف '},
        "final_notification" => {name_in_db: "Final Email to 3 Departments to Finalize Joining", subject: ' تمت مباشرة الموظف '},
        "reminder_update_jobseeker_offer_letter" => {name_in_db: "Reminder to Follow up with STC Reg Offer Letter", subject: 'تذكير تلقائي لمتابعة حالة العرض الوظيفي مع (STCS) '},
        "reminder_send_jobseeker_offer_letter" => {name_in_db: "Reminder to Share Offer Letter with Candidate", subject: ' تذكير تلقائي لمتابعة إرسال العرض للمرشح '},
        "reminder_update_status_jobseeker_offer_letter" => {name_in_db: "Update Status of Reply on Offer Letter from Candidate", subject: '  تذكير تلقائي لمتابعة الرد على العرض الوظيفي للمرشح '},

        "fill_evaluation_form_after_interview" => {name_in_db: "Reminder to Enter Evaluation", subject: '  إدخال نتيجة مقابلة شخصية لوظيفة إدخال نتيجة مقابلة شخصية '},
        "after_submit_evaluation_form" => {name_in_db: "Informing Requester about Completed Evaluation", subject: '  اكتمال نتيجة المقابلة الشخصية للمرشح على وظيفة '},
        "passed_interview" => {name_in_db: "Informing Recruitment Team of Successful Interview", subject: '  اجتياز المقابلة الشخصية للمرشح على وظيفة  '},

        "ask_approval_evaluation_form" => {name_in_db: "Ask Approval Evaluation Form", subject: "طلب الموافقة لنقل المرشح  لمرحلة ما بعد المقابلة الشخصية "},
        "requisition_approval_for_recruiter_evaluation_form" => {name_in_db: "Approved Evaluation Form", subject: "تمت الموافقة على استمارة تقييم"},
        "requisition_rejection_evaluation_form" => {name_in_db: "Rejected Evaluation Form", subject: "تم رفض استمارة تقييم"},

        "add_candidate_as_applied" => {name_in_db: "notify recruiters with new applied candidates", subject: "تم مشاركة مرشح جديد لوظيفة"},

        "reminder_uploading_documents" => {name_in_db: "reminder upload candidate document", subject: "طلب تزويد الوثائق المطلوبة للتوظيف لوظيفة"},


    }


    SUBJECT_EMAILS = {
        "invite_jobseeker_to_apply" => "Invite to Apply"
    }

    def self.get_twitter_client twitter_auth
      Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.secrets['twitter_consumer_key']
        config.consumer_secret     = Rails.application.secrets['twitter_consumer_secret']
        config.access_token        = twitter_auth[:access_token]
        config.access_token_secret = twitter_auth[:access_token_secret]
      end
    end

    def get_page_url content
      doc = Nokogiri::HTML.parse(content)
      doc.xpath('//a').map { |link| link['href'] }.last
    end

    def create_employer_notification subject, content, email_template_id, receivers, finished_action=nil, needed_action=nil
    #   :notifiable_id, :notifiable_type, :finished_action, :needed_action, :subject, :content
      receivers.each do |rec|
        next unless self.respond_to?(:id)

        user = User.find_by_email(rec[:email])

        notification_obj = {
            notifiable_id: self.id,
            notifiable_type: self.class.to_s,
            subject: subject,
            content: content,
            user_id: user.try(:id),
            email_template_id: email_template_id,
            finished_action: finished_action,
            needed_action: needed_action,
            page_url: get_page_url(content)
        }
        EmployerNotification.create(notification_obj) if notification_obj[:user_id].present?
      end
    end

    def change_subject old_subject
      old_subject += " رقم الطلب #{self.job.id}" if self.respond_to?(:job) && self.job.present?

      old_subject
    end

    # receivers = [{email: "recipient@theirdomain.com", name: "Recipient1"}]
    def send_email template_type, receivers, message={}, finished_action=nil, needed_action=nil

      email_template_obj = SendInvitation::TEMPLATES[template_type].present? ? EmailTemplate.find_by_name(SendInvitation::TEMPLATES[template_type][:name_in_db]) : nil

      current_time = DateTime.now.to_i

      message_obj = {
          subject:  SendInvitation::TEMPLATES[template_type].present? ? (SendInvitation::TEMPLATES[template_type][:subject] % message[:template_values]) : (message[:message_subject] || SendInvitation::SUBJECT_EMAILS[template_type]),
          from_name:  Rails.application.secrets[:ATS_NAME]["website_name"],
          to: receivers,
          html: message[:message_body] || (email_template_obj.present? && email_template_obj.body.present? ? (email_template_obj.body % message[:template_values]) : "NO BODY"),
          inline_css: true,
          from_email: Rails.application.secrets['SENDER_EMAIL'],
          attachments: message[:attachments],
          file_name: "#{template_type}_#{current_time}.txt",
          full_file_path: "#{Rails.root}/sending_mails/mails_content/#{template_type}_#{current_time}.txt"
      }

      message_obj[:subject] = change_subject message_obj[:subject]

      create_employer_notification message_obj[:subject], message_obj[:html], email_template_obj.try(:id), receivers,
                                   finished_action, needed_action

      file_content = "#{message_obj[:subject]}\n#{message_obj[:html]}\n"
      receivers.each{|rec| file_content += "#{rec[:email]},#{rec[:name]}\n"}
      File.open("sending_mails/mails_content/#{message_obj[:file_name]}", 'wb') {|f| f.write(file_content) }

      # begin
      #   file = File.open("sending_mails/mails_content/#{message_obj[:file_name]}", 'wb') do |file|
      #     file << "#{message_obj[:subject]}\n"
      #     file << "#{message_obj[:html]}\n"
      #     receivers.each{|rec| file << "#{rec[:email]},#{rec[:name]}\n"}
      #   end
      # rescue IOError => e
      #   #some error occur, dir not writable etc.
      #   puts e
      # ensure
      #   file.close unless file.nil?
      # end
      # SendInvitation::MANDRILL.messages.send message_obj
      # TODO: Remove this line
      # Notifier.sending(message_obj).deliver_now
      # Notifier.sending_by_mail_lib(message_obj)
      # puts "CALL NOTIFIER"
      # Notifier.sending_by_c_sharp_algorithm(message_obj)
      # Notifier.sending_by_c_sharp(message_obj)
      Notifier.delay(queue: 'sending_mails').sending_by_c_sharp(message_obj)
    end

    def send_email_template template_name ,vars , recipients , email_from , subject, attachments = []

      message_obj = {
          from_name:  Rails.application.secrets[:ATS_NAME]["website_name"],
          to: recipients,
          html: "message",
          subject: subject,
          inline_css: true,
          from_email: email_from,
          global_merge_vars: vars,
          attachments: attachments
      }

      # SendInvitation::MANDRILL.messages.send_template(template_name,[],message_obj)
      Notifier.sending(message_obj).deliver_now
    end

    def send_email_template_as_annoncer template_name ,vars , recipients , email_from , subject, attachments = []

      message_obj = {
          from_name:  "",
          to: recipients,
          html: "message",
          subject: subject,
          inline_css: true,
          from_email: email_from,
          global_merge_vars: vars,
          attachments: attachments
      }

      SendInvitation::MANDRILL.messages.send_template(template_name,[],message_obj)
    end



    # receivers = [{screen_name: "MohamedYakot1", image_url: ""}]
    def send_msg_twitter twitter_auth, template_type, receivers, message={}
      email_template_obj = EmailTemplate.find_by_name(SendInvitation::TEMPLATES[template_type])
      client = User.get_twitter_client twitter_auth

      message_body = message[:message_body] || email_template_obj.body % message[:template_values]
      receivers.each do |receiver|
        client.create_direct_message(receiver[:screen_name], message_body)
      end
    end
  end
end
