require 'spec_helper'

describe TwitterController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
    it "matches get twitter_path" do
      { :get => twitter_path }.should route_to(
        :controller => "twitter",
        :action => "index" )
    end
  end

  describe "GET 'oauth'" do
    it "should be successful" do
      get 'oauth'
      response.should be_redirect
    end
    it "matches get twitter_oauth_path" do
      { :get => twitter_oauth_path }.should route_to(
        :controller => "twitter",
        :action => "oauth" )
    end
  end

  describe "GET 'oauth_callback'" do
    it "should be successful" do
      get 'oauth_callback'
      response.should be_redirect
    end
    it "matches get twitter_oauth_callback_path" do
      { :get => twitter_oauth_callback_path }.should route_to(
        :controller => "twitter",
        :action => "oauth_callback" )
    end
  end

end
