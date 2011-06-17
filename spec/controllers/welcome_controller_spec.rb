require 'spec_helper'

describe WelcomeController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
    it "matches get root_path" do
      { :get => root_path }.should route_to(
        :controller => "welcome",
        :action => "index" )
    end
  end

end
