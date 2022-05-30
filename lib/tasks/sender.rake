namespace :sender do
  desc "sending mails"
  task sending_mails: :environment do
    Dir.foreach('sending_mails/mails_content') do |filename|
      next if filename == '.' or filename == '..'
      puts filename
      command = "dotnet run --project #{Rails.root.to_path}/sending_mails #{Rails.application.secrets['SENDER_EMAIL']} #{Rails.application.secrets['SENDER_EMAIL_PASSWORD']} #{Rails.application.secrets['DOMAIN']} #{Rails.application.secrets['SENDER_EMAIL_SMTP']} #{Rails.application.secrets['SENDER_EMAIL_PORT']} #{Rails.root.to_path}/sending_mails/mails_content/#{filename}"
      puts command
      system(command)
    end
  end



  desc "sending mails reset password"
  task sending_mails_custom: :environment do
    # system("dotnet run --project /home/mod/clients/mod/API/sending_mails noreply_healthacademy@scfhs.org.sa Sc@12345 scfhs.org.sa mail.scfhs.org.sa 25 /home/bloovo/clients/scfhs/API/sending_mails/mails_content/test.txt")
    command = "dotnet run --project #{Rails.root.to_path}/sending_mails #{Rails.application.secrets['SENDER_EMAIL']} #{Rails.application.secrets['SENDER_EMAIL_PASSWORD']} #{Rails.application.secrets['DOMAIN']} #{Rails.application.secrets['SENDER_EMAIL_SMTP']} #{Rails.application.secrets['SENDER_EMAIL_PORT']} #{Rails.root.to_path}/sending_mails/mails_content/test.txt"
    puts command
    system(command)
#    Dir.glob('sending_mails/mails_content/reset_password_*.txt') do |filename|
#      next if filename == '.' or filename == '..'
#      puts filename
#      command = "dotnet run --project #{Rails.root.to_path}/sending_mails #{Rails.application.secrets['SENDER_EMAIL']} #{Rails.application.secrets['SENDER_EMAIL_PASSWORD']} #{Rails.application.secrets['DOMAIN']} #{Rails.application.secrets['SENDER_EMAIL_SMTP']} #{Rails.application.secrets['SENDER_EMAIL_PORT']} #{Rails.root.to_path}/sending_mails/mails_content/#{filename}"
#      puts command
#      system(command)
#    end
  end
end