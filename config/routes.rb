Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/callback' => 'linebot#callback'
  post '/push' => 'linebot#push'
  get '/send' => 'linebot#send'
  root 'linebot#send'
end
