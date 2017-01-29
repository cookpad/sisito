Rails.application.config.tap do |config|
  YAML.load_file(Rails.root.join('config/sisito.yml')).tap do |yaml|
    config.sisito = {
      admin: yaml.fetch('admin').symbolize_keys,
      smtp: yaml.fetch('smtp'),
      digest: Digest.const_get(yaml.fetch('digest').upcase),
      header_links: yaml.fetch('header_links', {})
    }
  end
end
