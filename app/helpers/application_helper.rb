module ApplicationHelper
  def mail_link(bounce_mail, options = {target: '_blank'})
    if bounce_mail.link
      link_to(bounce_mail.recipient, bounce_mail.link, options)
    else
      bounce_mail.recipient
    end
  end

  def bounce_over?(whitelist_mail_created_at, bounce_mail_timestamp)
    buf = Rails.application.config.sisito.dig(:bounce_over, :buffer) || 0
    whitelist_mail_created_at.present? and
    bounce_mail_timestamp.present? and
    bounce_mail_timestamp > (whitelist_mail_created_at + buf)
  end
end
