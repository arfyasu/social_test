require 'oauth'
require 'json'

class TwitterController < ApplicationController
  # OAuthクライアントを初期化する
  def initialize
    super
    load_config_twitter
    @@consumer ||= OAuth::Consumer.new(
      "#{@twitter_settings['consumer_key']}", 
      "#{@twitter_settings['consumer_secret']}",
      { :site => "http://twitter.com" }
    )
  end

  def index
    if session[:access_token_twitter]
      response = @@consumer.request(
        :get,
        '/account/verify_credentials.json',
        session[:access_token_twitter],
        { :scheme => :query_string }
      )
      case response
      when Net::HTTPSuccess
        @user_info = JSON.parse(response.body)
        unless @user_info['screen_name']
          flash[:notice] = "Authentication failed"
          redirect_to :action => :index
          return
        end
      else
        RAILS_DEFAULT_LOGGER.error "Failed to get user info via OAuth"
        flash[:notice] = "Authentication failed"
        redirect_to :action => :index
        return
      end
    end
  end

  # twitter認証処理
  def oauth
    request_token = @@consumer.get_request_token(
      :oauth_callback => "http://#{request.host_with_port}/twitter/oauth_callback"
    )
    session[:request_token_twitter] = {
      token: request_token.token,
      secret: request_token.secret
    }
    redirect_to request_token.authorize_url
    return
  end

  # 認証後、セッションにアクセストークンを保持する
  def oauth_callback
    if params[:oauth_token]
      request_token = OAuth::RequestToken.new(
        @@consumer,
        session[:request_token_twitter][:token],
        session[:request_token_twitter][:secret]
      )
      access_token = request_token.get_access_token(
        {},
        :oauth_token => params[:oauth_token],
        :oauth_verifier => params[:oauth_verifier]
      )
      p access_token
      session[:access_token_twitter] = OAuth::AccessToken.new(
        @@consumer,
        access_token.token,
        access_token.secret
      )
    end
    session.delete :request_token_twitter
    redirect_to twitter_path
  end

  private
    # configからtwitterの設定情報を取得する
    def load_config_twitter
      @twitter_settings ||= load_config_oauth[Rails.env]['twitter']
    end

end
