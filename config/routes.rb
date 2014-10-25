Rails.application.routes.draw do
  root 'setup#index'

  devise_for :users, skip: [:sessions]

  resources :guests, only: [:index, :create]

  get '/setup', to: 'setup#index', as: 'setup'
  post '/setup', to: 'setup#perform', as: 'perform_setup'

  resources :machines do
    member do
      post 'start'
      post 'pause'
      post 'resume'
      post 'stop'
      post 'force_stop'
      post 'restart'
      post 'force_restart'

      post 'mount_iso'

      get 'state'
      get 'vnc'
    end

    resources :disks do
      member do
        post 'resize'
        post 'snapshot'
      end
    end
  end

  get '/progress/:id', to: 'progress#progress', as: 'progress'
  get '/machine_progress/:id', to: 'progress#machine', as: 'machine_progress'
end
