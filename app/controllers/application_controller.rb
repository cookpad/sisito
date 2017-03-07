class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  if Rails.application.config.sisito.dig(:omniauth, :google_client_id)
    before_action :authenticate_user!, if: :authenticate?
  end

  private

  def authenticate_user!
    if session[:auth].blank?
      redirect_to '/auth/google_oauth2'
    end
  end

  def authenticate?
    true
  end
end
