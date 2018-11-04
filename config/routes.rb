Rails.application.routes.draw do
  root to: 'transfers#new'
  resource :transfers, only: [:new, :create]
end
