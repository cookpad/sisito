module ApplicationHelper
  def mail_link(bounce_mail, options = {target: '_blank'})
    if bounce_mail.link
      link_to(bounce_mail.recipient, bounce_mail.link, options)
    else
      bounce_mail.recipient
    end
  end
end
