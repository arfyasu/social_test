require 'spec_helper'

describe FacebookController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
    it "matches get facebook_path" do
      { :get => facebook_path }.should route_to("facebook#index")
    end
  end

  describe "GET 'oauth'" do
    it "should be successful" do
      get 'oauth'
      response.should be_redirect
    end
    it "matches get facebook_oauth_path" do
      { :get => facebook_oauth_path }.should route_to("facebook#oauth")
    end
  end

  describe "GET 'callback'" do
    it "should be successful" do
      get 'callback'
      response.should be_redirect
    end
    it "matches get facebook_callback_path" do
      { :get => facebook_callback_path }.should route_to("facebook#callback")
    end
  end
  
end
