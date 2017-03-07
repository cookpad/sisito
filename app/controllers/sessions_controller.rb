class SessionsController < ApplicationController
  def callback
    auth = request.env['omniauth.auth']
    session[:auth] = auth.info
    redirect_to root_path
  end

  def failure
    render text: '401 Unauthorized', status: :unauthorized
  end

  def authenticate?
    false
  end
end
