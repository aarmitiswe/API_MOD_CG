# require "omnicontacts"

# Rails.application.middleware.use OmniContacts::Builder do
#     importer :gmail, Rails.application.secrets["gmail_client_id"], Rails.application.secrets["gmail_cliend_secret"], {redirect_path: "/invites/gmail/contact_callback", max_results: 100000}
#     # TODO: Change key & secret when deploy to use web_application instead of desktop app.
#     # To be able test in localhost .. I create Desktop App to accept :3000
#     importer :yahoo, Rails.application.secrets["yahoo_client_id"], Rails.application.secrets["yahoo_cliend_secret"], {callback_path: "/invites/yahoo/contact_callback"}
#     importer :outlook, Rails.application.secrets["outlook_client_id"], Rails.application.secrets["outlook_cliend_secret"], {redirect_path: "/invites/outlook/contact_callback"}
# end