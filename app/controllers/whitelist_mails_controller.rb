class WhitelistMailsController < ApplicationController
  before_action :set_whitelist_mail, only: [:destroy, :show]

  def index
    @whitelist_mails = WhitelistMail.select('whitelist_mails.*', 'MAX(bounce_mails.timestamp) AS max_bounce_mail_timestamp')
                                .joins('LEFT JOIN bounce_mails' +
                                       '  ON whitelist_mails.recipient = bounce_mails.recipient ' +
                                       ' AND whitelist_mails.senderdomain = bounce_mails.senderdomain')
                                .group(:recipient, :senderdomain)
                                .order(created_at: :desc)
                                .page(params[:page])
  end

  def new
    @whitelist_mail = WhitelistMail.new
  end

  def create
    @whitelist_mail = WhitelistMail.new(whitelist_mail_params)

    if @whitelist_mail.save
      redirect_to whitelist_mails_path, notice: 'Whitelist mail was successfully created.'
    else
      render :new
    end
  end

  def show
    bounce_mail_id = BounceMail.where(recipient: @whitelist_mail.recipient).maximum(:id)
    @bounce_mail = BounceMail.find(bounce_mail_id)

    @history = BounceMail.where(recipient: @bounce_mail.recipient, senderdomain: @bounce_mail.senderdomain)
                         .order(timestamp: :desc)
  end

  def register
    whitelist_mail = WhitelistMail.new(whitelist_mail_params)

    unless WhitelistMail.exists?(recipient: whitelist_mail.recipient, senderdomain: whitelist_mail.senderdomain)
      whitelist_mail.save!
    end

    if params[:return_to]
      redirect_to params[:return_to]
    else
      redirect_to whitelist_mails_path
    end
  end

  def deregister
    whitelist_mail = WhitelistMail.where(recipient: whitelist_mail_params[:recipient], senderdomain: whitelist_mail_params[:senderdomain]).take

    if whitelist_mail
      whitelist_mail.destroy!
    end

    if params[:return_to]
      redirect_to params[:return_to]
    else
      redirect_to whitelist_mails_path
    end
  end

  def destroy
    @whitelist_mail.destroy
    redirect_to whitelist_mails_path, notice: 'Whitelist mail was successfully destroyed.'
  end

  private

  def set_whitelist_mail
    @whitelist_mail = WhitelistMail.find(params[:id])
  end

  def whitelist_mail_params
    params.require(:whitelist_mail).permit(:recipient, :senderdomain)
  end
end
