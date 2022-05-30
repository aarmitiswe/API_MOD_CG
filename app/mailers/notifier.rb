class Notifier < ApplicationMailer
  # :parts_order, :content_type, :body, :template_name, :template_path
  def sending message_obj
    # @account = recipient
    # mail(to: recipient.email_address_with_name,
    #      bcc: ["bcc@example.com", "Order Watcher <watcher@example.com>"])

    receiver = ["#{message_obj[:to].first[:name]} <#{message_obj[:to].first[:email]}>"]
    bcc = message_obj[:to][1..-1].map{|obj| "#{obj[:name]} <#{obj[:email]}>"}

    mail(to: receiver, bcc: bcc, subject: message_obj[:subject], attachments: message_obj[:attachments],
         content_type: 'text/html',
         body: message_obj[:html],
         from: "#{message_obj[:from_name]} <#{message_obj[:from_email]}>")
  end

  def sending_by_mail_lib message_obj
    mail = Mail.new do
      from    message_obj[:from_email]
      to      message_obj[:to].first[:email]
      subject message_obj[:subject]
      # body    message_obj[:html]
      html_part do
        content_type 'text/html; charset=UTF-8'
        body message_obj[:html]
        # body '<h1>This is HTML</h1>'
      end
    end

    mail.delivery_method :sendmail

    mail.deliver
  end

  def sending_by_c_sharp message_obj={}
    puts "sending_by_c_sharp"
    begin
      message_obj[:to] ||= [{email: 'bloovo2017@gmail.com'}]
      command = "dotnet run --project #{Rails.root.to_path}/sending_mails #{message_obj[:from_email] || Rails.application.secrets['SENDER_EMAIL']} #{Rails.application.secrets['SENDER_EMAIL_PASSWORD']} #{Rails.application.secrets['DOMAIN']} #{Rails.application.secrets['SENDER_EMAIL_SMTP']} #{Rails.application.secrets['SENDER_EMAIL_PORT']} #{message_obj[:full_file_path]}"
      puts command

      puts message_obj[:full_file_path]
      puts message_obj
      puts message_obj["full_file_path"]
      system(command)

      puts "DONE SENDING C#"
    rescue Exception => e
      puts e.message
      return nil
    end
  end


  def sending_by_c_sharp_algorithm message_obj={}
    puts "sending_by_c_sharp_algorithm"
    begin
      message_obj[:to] ||= [{email: 'bloovo2017@gmail.com'}]
      command = "dotnet run --project #{Rails.root.to_path}/sending_mails #{message_obj[:from_email] || Rails.application.secrets['SENDER_EMAIL']} #{Rails.application.secrets['SENDER_EMAIL_PASSWORD']} #{Rails.application.secrets['DOMAIN']} #{Rails.application.secrets['SENDER_EMAIL_SMTP']} #{Rails.application.secrets['SENDER_EMAIL_PORT']} #{message_obj[:full_file_path]}"
      puts command

      puts message_obj[:full_file_path]
      puts message_obj
      puts message_obj["full_file_path"]
      system(command)

      puts "DONE SENDING C#"
    rescue Exception => e
      puts e.message
      return nil
    end
  end
end
