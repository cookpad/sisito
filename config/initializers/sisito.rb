Rails.application.config.tap do |config|
  yaml = YAML.load_file(Rails.root.join('config/sisito.yml'))
  config.sisito = yaml.with_indifferent_access
  config.sisito[:digest] = Digest.const_get(config.sisito.fetch(:digest).upcase)
end
