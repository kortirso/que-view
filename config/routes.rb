# frozen_string_literal: true

Que::View::Engine.routes.draw do
  resources :jobs, only: %i[index show update destroy] do
    post :reschedule_all, on: :collection
    delete :destroy_all, on: :collection
  end

  root 'welcome#index'
end
