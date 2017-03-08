if Rails.application.config.sisito.dig(:omniauth, :google_client_id)
  Rails.application.config.middleware.use OmniAuth::Builder do
    omniauth = Rails.application.config.sisito.fetch(:omniauth)

    provider_options = {provider_ignores_state: true}
    provider_options[:hd] = Array(omniauth[:hd]) if omniauth[:hd]

    provider :google_oauth2,
      omniauth.fetch(:google_client_id),
      omniauth.fetch(:google_client_secret),
      provider_options
  end

  OmniAuth.config.on_failure = Proc.new do |env|
    OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  end
end
