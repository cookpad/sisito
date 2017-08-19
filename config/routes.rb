Rails.application.routes.draw do
  root to: 'stats#index'

  match 'bounce_mails', to: 'bounce_mails#index', via: [:get, :post]
  resources :bounce_mails, only: [:show]

  post 'whitelist_mails/register', to: 'whitelist_mails#register'
  post 'whitelist_mails/deregister', to: 'whitelist_mails#deregister'
  resources :whitelist_mails, only: [:index, :new, :create, :destroy, :show]

  get 'admin/download', to: 'admin#download'
  match 'admin/search', to: 'admin#search', via: [:get, :post]
  resources :admin, only: [:index, :show, :destroy]

  get 'sender', to: 'sender#index'
  post 'sender', to: 'sender#create'
  get 'sent', to: 'sender#sent'

  get  'auth/:provider/callback', to: 'sessions#callback'
  post 'auth/:provider/callback' , to: 'sessions#callback'
  get  'auth/failure', to: 'sessions#failure'

  get 'status', to: 'status#index'
end
