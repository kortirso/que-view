# frozen_string_literal: true

Que::View::Engine.routes.draw do
  resources :jobs, only: %i[index show update destroy] do
    post :reschedule_all, on: :collection
    delete :destroy_all, on: :collection
  end
  resources :queue_metrics, only: %i[index]

  root 'welcome#index'
end
