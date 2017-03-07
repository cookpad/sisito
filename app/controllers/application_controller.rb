class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!, if: :authenticate?

  private

  def authenticate_user!
    if Rails.application.config.sisito.dig(:omniauth, :google_client_id) and session[:auth].blank?
      redirect_to '/auth/google_oauth2'
    end
  end

  def authenticate?
    true
  end
end
