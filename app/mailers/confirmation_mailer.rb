class ConfirmationMailer < ApplicationMailer
  def email(confirmation_mail)
    options = Rails.application.config.sisito.fetch(:smtp).fetch(confirmation_mail.from)
    delivery_options = {address: options[:host], port: options[:port]}

    mail(from: confirmation_mail.from,
         to: confirmation_mail.to,
         subject: confirmation_mail.subject,
         body: confirmation_mail.body)
  end
end
