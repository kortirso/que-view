# frozen_string_literal: true

Rails.application.routes.draw do
  mount Que::View::Engine => '/que-view'
end
