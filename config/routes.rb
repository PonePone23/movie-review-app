Rails.application.routes.draw do
  get 'notifications/index'
  get 'feedbacks/new'
  get 'feedbacks/create'
  get '/up_coming', to: 'movies#up_coming'


  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }
  resources :histories, only: [:index, :destroy] do
    collection do
      delete 'delete_all'
    end
  end
  resources :activities do
    member do
      delete :delete_single
    end
    collection do
      delete 'delete_all', to: 'activities#delete_all'
      get 'export'
    end
  end
  get 'users/dashboard', to: 'users#dashboard'
  delete '/users/:user_id/activities/delete_all', to: 'activities#delete_user_activities', as: 'delete_user_activities'

  devise_scope :user do
    get '/users/sign_out' => 'users/sessions#destroy'
    get 'users/new_registration', to: 'users#new_registration', as: :new_registration
    post 'users/create_registration', to: 'users#create_registration', as: :create_registration
  end

  root "movies#index"

  resources :movies do
# config/routes.rb
    match 'find_cast_relate_movie/:cast/:movie_id', to: 'movies#find_cast_relate_movie', via: [:get, :post], on: :collection, as: 'find_cast_relate_movie', constraints: { cast: /[^\/]+/ }
    match 'find_director_relate_movie/:director/:movie_id', to: 'movies#find_director_relate_movie', via: [:get, :post], on: :collection, as: 'find_director_relate_movie', constraints: { director: /[^\/]+/ }
    resources :users do
      resources :comments do
        put 'approve', on: :member
      end
    end
  end

  resources :users do
    collection do
      get 'search'
      get 'export'
      post 'import'
    end
    member do
      delete 'delete_image'
      get 'saved_movies'
    end
    get 'unsave', on: :member
    collection do
      get :filter_by_user
      get :filter_by_time
      get :dashboard
    end
  end

  resources :genres do
    collection do
      get 'search'
      get 'export'
      post 'import'
    end
    member do
      get 'movies'
    end
    get 'save', on: :member
    get 'unsave', on: :member
  end

  resources :years do
    collection do
      get 'search'
      get 'export'
      post 'import'
    end
    get 'save', on: :member
    get 'unsave', on: :member
  end

  resources :movies do
    resources :ratings, only: [:create,:destroy]
    get 'save', on: :member
    get 'unsave', on: :member
  end

  get '/search',to: "movies#search"
  get 'movies_by_genre/:genre_id', to: 'movies#by_genre', as: 'movies_by_genre'

  resources :feedbacks, only: [:new, :create]
  resources :saved_movies, only: [:create, :index]
  resources :notifications, only: [:index, :destroy] do
    collection do
      delete 'delete_all', to: 'notifications#delete_all'
    end
  end

  # Related to discussions
  resources :discussions do
    resources :reactions, only: [:create, :destroy]
    resources :replies, only: [:create, :destroy]
  end
end

