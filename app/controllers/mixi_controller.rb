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
       :access_token_url => 'https://secure.mixi-platform.com/2/token',
       :refresh_token_url => 'https://secure.mixi-platform.com/2/token'}
    )
  end

  def index
    if session[:access_token_mixi]
      res = get_profile
      if res.blank?
        # プロフィールを取得できなかった場合アクセストークンをリフレッシュする
        refresh
        res = get_profile
        if res.blank?
          flash[:error] = "get profile failed."
          return
        end
      end
      @profile = JSON.parse(res)["entry"]
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
      p access_token
      set_access_token_to_session(access_token) if access_token
    end
    redirect_to mixi_path
  end
  
  private

    # configからmixi設定情報を取得する
    def load_config_mixi
      @mixi_settings ||= load_config_oauth[Rails.env]['mixi']
    end

    # プロフィール情報を取得する
    def get_profile
      begin
        access_token = OAuth2::AccessToken.new(@@client, session[:access_token_mixi][:token])
        p access_token
        access_token.get("http://api.mixi-platform.com/2/people/@me/@self")
      rescue
        p "access token unuse!"
        nil
      end
    end
    
    # access_tokenをセッションにセットする
    def set_access_token_to_session(access_token)
      session.delete :access_token_mixi
      session[:access_token_mixi] = {
        :token => access_token.token,
        :refresh_token => access_token.refresh_token
      }
    end

    # アクセストークンをリフレッシュし、新しいアクセストークンを取得する
    def refresh
      refreshed_token = @@client.web_server.refresh_access_token(
        session[:access_token_mixi][:refresh_token]
      )
      p refreshed_token
      set_access_token_to_session(refreshed_token) if refreshed_token
      p session[:access_token_mixi]
    end
  

end 
