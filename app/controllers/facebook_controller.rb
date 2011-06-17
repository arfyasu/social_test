require "oauth2"
require 'json'

class FacebookController < ApplicationController

  # OAuthクライアントを初期化する
  def initialize
    super
    load_config_facebook
    @@client ||= OAuth2::Client.new(
      "#{@facebook_settings['application_id']}", 
      "#{@facebook_settings['secret_key']}",
      :site => 'https://graph.facebook.com'
    )
  end

  # 認証されている場合は、いいね一覧を取得する
  def index
    if session[:access_token]
      access_token = OAuth2::AccessToken.new(@@client, session[:access_token])
      @likes = JSON.parse(access_token.get("/me/likes"))["data"]
    end
  end

  # 認証処理
  def oauth
    redirect_to @@client.web_server.authorize_url(
      :redirect_uri => "#{@facebook_settings['callback_url']}", 
      :scope => 'read_stream,user_about_me,user_likes,user_activities,user_work_history'
    )
  end

  # 認証後、セッションにアクセストークンを保持する
  def callback
    if params[:code]
      access_token = @@client.web_server.get_access_token(
        params[:code],
        :redirect_uri => "#{@facebook_settings['callback_url']}", 
      )
      session[:access_token] = access_token.token if access_token
    end
    redirect_to facebook_path
  end


  private

    # configからfacebookの設定情報を取得する
    def load_config_facebook
      @facebook_settings ||= load_config_oauth[Rails.env]['facebook']
    end

end
