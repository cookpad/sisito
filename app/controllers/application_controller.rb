class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_pervious_url

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

  def set_pervious_url
    session[:pervious_url] = request.original_url
  end
end
