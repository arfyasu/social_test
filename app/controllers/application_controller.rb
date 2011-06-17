class ApplicationController < ActionController::Base
  protect_from_forgery

  # configから取得する
  def load_config_oauth
    YAML::load(File.open("#{Rails.root}/config/oauth.yml"))
  end

end
