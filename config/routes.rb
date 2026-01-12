Rails.application.routes.draw do
  resources :tasks , defaults: {format: 'json'} do
    collection do
      get :report
    end
    member do
      post :status, to: "tasks#update_status", defaults: {format: 'json'}
      post :duplicate
    end
  end
  resources :genres
end
