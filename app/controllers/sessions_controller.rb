class SessionsController < ApplicationController
  def callback
    auth = request.env['omniauth.auth']
    allow_users = Rails.application.config.sisito.dig(:omniauth, :allow_users)

    if allow_users.blank? or allow_users.include?(auth.info.email)
      session[:auth] = auth.info
      redirect_to return_path
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

  private

  def return_path
    if request.env['omniauth.origin'].present?
      CGI.unescape(request.env['omniauth.origin'])
    else
      root_path
    end
  end
end
