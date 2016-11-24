RuCaptcha.configure do
  self.len = 4
  self.font_size = 45
  self.cache_limit = 100
  # Expire in 10 mins
  self.expires_in = 1200
end
