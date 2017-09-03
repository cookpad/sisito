Rails.application.config.sisimai = {
  reasons: Sisimai.reason.keys.map(&:to_s).map(&:downcase)
}
