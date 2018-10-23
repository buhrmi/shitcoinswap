class ApplicationMailer < ActionMailer::Base
  default from: I18n.t 'from_mail'
  layout 'mailer'
end
