# frozen_string_literal: true

Que::View::Engine.routes.draw do
  resources :jobs, only: %i[index destroy] do
    delete :destroy_all, on: :collection
  end

  root 'welcome#index'
end
