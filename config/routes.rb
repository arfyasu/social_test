Socialsample::Application.routes.draw do


  root :to => "welcome#index"
  
  match "twitter" => "twitter#index"
  get "twitter/oauth"
  get "twitter/oauth_callback"

  
  match "facebook" => "facebook#index"
  get "facebook/oauth"
  get "facebook/callback"


  match "mixi" => "mixi#index"
  get "mixi/auth"
  get "mixi/callback"

end
