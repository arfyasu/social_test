require "oauth2"

class MixiController < ApplicationController

  # OAuthクライアントを初期化する
  def initialize
    super
    load_config_mixi
    @@client ||= OAuth2::Client.new(
      "#{@mixi_settings['consumer_key']}", 
      "#{@mixi_settings['consumer_secret']}",
      {:site => 'https://mixi.jp/',
       :authorize_url => 'connect_authorize.pl',
       :access_token_url => 'https://secure.mixi-platform.com/2/token'}
    )
  end

  def index
    if session[:access_token_mixi]
      access_token = OAuth2::AccessToken.new(@@client, session[:access_token_mixi])
      #TODO: アクセストークンの有効期限が切れた場合はアクセストークンを再発行する
      @profile = JSON.parse(access_token.get("http://api.mixi-platform.com/2/people/@me/@self"))["entry"]
    end
  end

  def auth
    redirect_to @@client.web_server.authorize_url(
      :redirect_uri => "#{@mixi_settings['callback_url']}", 
      :scope => 'r_profile'
    )
  end

  def callback
    if params[:code]
      access_token = @@client.web_server.get_access_token(
        params[:code],
        {:redirect_uri => "#{@mixi_settings['callback_url']}"}
      )
#      p access_token
      session[:access_token_mixi] = access_token.token if access_token
    end
    redirect_to mixi_path
  end
  
  private

    # configからmixi設定情報を取得する
    def load_config_mixi
      @mixi_settings ||= load_config_oauth[Rails.env]['mixi']
    end

end 
