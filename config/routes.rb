require "sidekiq/web"


Rails.application.routes.draw do
  get "static_pages/help"
  get "images/ogp"
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # root_path
  root "tops#index"

  # 使い方画面ルート
  get  "static_pages/help", to: "static_pages#help"

  # 検索ルート
  get "search", to: "search#index"
  get "search/playlists", to: "search#playlists"


  # autoCompleteルート
  resources :clips do
    get :search, on: :collection
  end

  # プレイリストクリップ用ルート
  resources :playlist_clips
  # IDを必要とせず、プレイリストにクリップを追加できるアクションを追加する
  post "add_clip_in_playlist", to: "playlist_clips#add_clip_in_playlist"

  # プレイリストのルート
  resources :playlists do
    resource :likes, only: %i[create destroy]
  end

  # CI/CD用route
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA用route
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Sidekiq認証
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end

  # Sidekiq
  mount Sidekiq::Web => "/mgmt/sidekiq"
end
