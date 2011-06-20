require 'spec_helper'

describe MixiController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
    it "matches get mixi_path" do
      { :get => mixi_path }.should route_to("mixi#index")
    end
  end

  describe "GET 'auth'" do
    it "should be successful" do
      get 'auth'
      response.should be_redirect
    end
    it "matches get mixi_auth_path" do
      { :get => mixi_auth_path }.should route_to("mixi#auth")
    end
  end

  describe "GET 'callback'" do
    it "should be successful" do
      get 'callback'
      response.should be_redirect
    end
    it "matches get mixi_callback_path" do
      { :get => mixi_callback_path }.should route_to("mixi#callback")
    end
  end

end
