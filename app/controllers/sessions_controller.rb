class SessionsController < ApplicationController
  skip_before_action :set_pervious_url

  def callback
    auth = request.env['omniauth.auth']
    allow_users = Rails.application.config.sisito.dig(:omniauth, :allow_users)

    if allow_users.blank? or allow_users.include?(auth.info.email)
      session[:auth] = auth.info
      redirect_to session[:pervious_url] || root_path
    else
      render plain: '401 Unauthorized', status: :unauthorized
    end
  end

  def failure
    render plain: '401 Unauthorized', status: :unauthorized
  end

  def authenticate?
    false
  end
end
