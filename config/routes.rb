Rails.application.routes.draw do
  root to: 'transfers#new'
  resources :transfers, only: [:new, :create, :show]
end
