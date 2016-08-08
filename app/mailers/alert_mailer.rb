class AlertMailer < ActionMailer::Base
  default from:    Settings.mail.from,
          to:      Settings.mail.system_to,
          subject: "MELPO System Alert"

  def alert_mail(header, request, exception, current_user, footer)
    @subject = "MELPO System Alert"
    @header = header
    @request = request
    @exception = exception
    @user = current_user
    @footer = footer
    mail
  end
end
