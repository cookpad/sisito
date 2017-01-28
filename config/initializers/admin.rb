YAML.load_file(Rails.root.join('config/admin.yml')).tap do |yaml|
  Rails.application.config.admin = yaml.symbolize_keys
end
