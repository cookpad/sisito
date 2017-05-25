Rails.application.config.tap do |config|
  yaml = YAML.load_file(Rails.root.join('config/sisito.yml'))
  config.sisito = yaml.with_indifferent_access
  config.sisito[:digest] = Digest.const_get(config.sisito.fetch(:digest).upcase)

  if (secret_file = config.sisito.fetch(:admin, {})[:secret_file])
    secret_file = Rails.root.join(secret_file) unless secret_file.start_with?('/')
    secret = YAML.load_file(secret_file)
    config.sisito[:admin][:username] = secret.fetch('username')
    config.sisito[:admin][:password] = secret.fetch('password')
  end
end
