using System;
using System.Linq;
using System.IO;
using System.Security.Cryptography;
using System.Text;

using System.Collections.Generic;
using System.Net.Mail;
using System.Net.Mime;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Net;
using System.Security.Cryptography.X509Certificates;
using System.Net.Security;

namespace Projects
{
    class Message
    {
        public string SenderMail { get; set; }
        public string SenderMailPassword { get; set; }
        public string SenderMailDomain { get; set; }
        public string SenderMailSmtp { get; set; }
        public string SenderMailPort { get; set; }
        public string ToMail { get; set; }
        public string Subject { get; set; }
        public string Body { get; set; }
        public string FileName { get; set; }

        public Message(string senderMail, string senderMailPassword, string senderMailDomain, string senderMailSmtp, string senderMailPort, string fileName)
        {
            SenderMail = senderMail;
            SenderMailPassword = senderMailPassword;
            SenderMailDomain = senderMailDomain;
            SenderMailSmtp = senderMailSmtp;
            SenderMailPort = senderMailPort;
            FileName = fileName;
        }
    }

    class Program
    {

        public static void NEVER_EAT_POISON_Disable_CertificateValidation()
        {
            // Disabling certificate validation can expose you to a man-in-the-middle attack
            // which may allow your encrypted message to be read by an attacker
            // https://stackoverflow.com/a/14907718/740639
            ServicePointManager.ServerCertificateValidationCallback =
                delegate (
                    object s,
                    X509Certificate certificate,
                    X509Chain chain,
                    SslPolicyErrors sslPolicyErrors
                ) {
                    return true;
                };
        }

        public static void sending_mails(Message message)
        {
            try
            {
                MailMessage mailMsg = new MailMessage();

                // To
                //mailMsg.To.Add(new MailAddress(message.ToMail, message.ToMail));

                // From
                mailMsg.From = new MailAddress(message.SenderMail, message.SenderMail);

                // Subject and multipart/alternative Body
                mailMsg.Subject = message.Subject;
                //string text = message.Body;
                string html = message.Body;

                string filePath = message.FileName;

                Console.WriteLine("FILE PATH: " + filePath);

                if (File.Exists(filePath))
                {
                    Console.WriteLine("OPEN FILE CORRECT!");
                    // Read a text file line by line.
                    string[] lines = File.ReadAllLines(filePath);
                    mailMsg.Subject = lines[0];
                    html = lines[1];
                    for (int i = 2; i < lines.Length; i++) {
                        string[] to_mail = lines[i].Split(',');
                        if (to_mail.Length >= 2) {
                            mailMsg.To.Add(new MailAddress(to_mail[0], to_mail[1]));
                        }
                    }

                    File.Delete(filePath);
                    Console.WriteLine(filePath + " is deleted.");
                }
                else {
                    Console.WriteLine("FAIL TO FIND THE FILE!");
		            return;
                }
                //mailMsg.AlternateViews.Add(AlternateView.CreateAlternateViewFromString(text, null, MediaTypeNames.Text.Plain));
                mailMsg.AlternateViews.Add(AlternateView.CreateAlternateViewFromString(html, null, MediaTypeNames.Text.Html));

                // Init SmtpClient and send
                SmtpClient smtpClient = new SmtpClient(message.SenderMailSmtp, Convert.ToInt32(message.SenderMailPort));
                smtpClient.EnableSsl = true;
                smtpClient.UseDefaultCredentials = false;

                //smtpClient.
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(message.SenderMail, message.SenderMailPassword);
                smtpClient.Credentials = credentials;

                // Console.WriteLine(message.SenderMail);
                // Console.WriteLine(message.SenderMailPassword);
                // Console.WriteLine(message.SenderMailDomain);
                // Console.WriteLine(message.SenderMailSmtp);
                // Console.WriteLine(message.SenderMailPort);
                // Console.WriteLine(message.ToMail);
                // This lines for MOD ONLY!
                if (message.SenderMail.Contains("mod.mil")) {

                    Console.WriteLine("MOD MAIL");

                    var cred = new NetworkCredential(message.SenderMail, message.SenderMailPassword);
                    var cache = new CredentialCache();
                    cache.Add(message.SenderMailSmtp, Convert.ToInt32(message.SenderMailPort), "Basic", cred);
                    smtpClient.Credentials = cache;

                    NEVER_EAT_POISON_Disable_CertificateValidation();
                }

                smtpClient.Send(mailMsg);

                Console.WriteLine("SENT DONE!");
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);

                Console.WriteLine(ex.InnerException);
            }

        }

        static void sendAllMails(String folderPath, Message message)
        {
            Console.WriteLine("folderPath: " + folderPath);
            foreach (string file in Directory.EnumerateFiles(folderPath, "*.txt"))
            {
                //string contents = File.ReadAllText(file);
                message.FileName = file;

                sending_mails(message);
            }
        }

        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");

            Message message = null;
            String folderName = null;

            if (args != null && args.Length > 0 && args[0] != null)
            {
                //email = args[0];
                //body = args[1];
                //string senderMail, string senderMailPassword, string senderMailDomain, string senderMailSmtp, string senderMailPort, string toMail, string subject, string body
                message = new Message(args[0], args[1], args[2], args[3], args[4], args[5]);
                folderName = args[5].TrimEnd('/').Remove(args[5].LastIndexOf('/') + 1);
            }

            sending_mails(message);
            sendAllMails(folderName, message);
            Console.WriteLine("DONE!");

            //string filePath = "/Users/moe/web_applications/bloovo/bloovo_api/sending_mails/mails_content/new_user_1595428091.txt";

            //if (File.Exists(filePath))
            //{
            //    Console.WriteLine("OPEN FILE CORRECT!");
            //    // Read a text file line by line.
            //    string[] lines = File.ReadAllLines(filePath);
            //    foreach (string line in lines)
            //        Console.WriteLine(line);
            //}
            //else
            //{
            //    Console.WriteLine("FAIL TO FIND THE FILE!");
            //}
        }
    }
}
