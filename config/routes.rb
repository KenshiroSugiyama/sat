Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/callback' => 'linebot#callback'
  post '/push' => 'linebot#push'
  post '/create' => 'linebot#create'
  get '/send' => 'linebot#send_message'
  get '/name' => 'linebot#name'
  root 'linebot#send_message'
end
