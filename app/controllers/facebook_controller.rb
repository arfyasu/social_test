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
    if session[:access_token_facebook]
      res = get_likes
      if res.blank?
        session.delete :access_token_facebook
#        #TODO: 無限ループの可能性があるため検証の必要あり
#        oauth
        return
      end
      @likes = JSON.parse(res)["data"]
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
      p access_token
      if access_token
        session[:access_token_facebook] = {
          :token => access_token.token,
          :code => params[:code],
          :expires_at => access_token.expires_at
        }
        p session[:access_token_facebook]
      end
    end
    redirect_to facebook_path
  end
  
  def refresh
    access_token = @@client.web_server.get_access_token(
      session[:access_token_facebook][:token],
      :redirect_uri => "#{@facebook_settings['callback_url']}", 
    )
    session[:access_token_facebook] = access_token.token if access_token
  end


  private

    # configからfacebookの設定情報を取得する
    def load_config_facebook
      @facebook_settings ||= load_config_oauth[Rails.env]['facebook']
    end
    
    # いいね一覧を取得する
    def get_likes
      begin
        access_token = OAuth2::AccessToken.new(@@client, session[:access_token_facebook][:token])
        p access_token
        access_token.get("/me/likes")
      rescue
        p "access token unuse!"
        nil
      end
    end

end
