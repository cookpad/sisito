Rails.application.routes.draw do
  root to: 'stats#index'

  match 'bounce_mails', to: 'bounce_mails#index', via: [:get, :post]
  resources :bounce_mails, only: [:show]

  post 'whitelist_mails/register', to: 'whitelist_mails#register'
  resources :whitelist_mails, only: [:index, :new, :create, :destroy]

  get 'admin/download', to: 'admin#download'
  resources :admin, only: [:index, :show, :destroy]

  get 'sender', to: 'sender#index'
  post 'sender', to: 'sender#create'
  get 'sent', to: 'sender#sent'
end
