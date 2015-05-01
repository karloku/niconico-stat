Rails.application.routes.draw do

  root :to => redirect('/tags')

  resources :tags, only: [:index, :show] do
    get "/searches" => "tags#search", on: :collection
    resources :videos, only: [:index]
  end
end
