# frozen_string_literal: true

describe Que::View::WelcomeController do
  routes { Que::View::Engine.routes }

  let(:configuration) { Que::View::Configuration.new }

  before do
    allow(Que::View).to receive_messages(configuration: configuration)
  end

  describe 'GET#index' do
    context 'without authorization' do
      before { get :index }

      it 'renders page' do
        expect(response).to be_successful
      end
    end

    context 'with authorization' do
      before do
        configuration.ui_username = 'username'
        configuration.ui_password = 'password'
        configuration.ui_secured_environments = ['test']
      end

      context 'without valid username/password' do
        before { get :index }

        it 'does not render page' do
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'with valid username/password' do
        before do
          create :que_job
          create :que_job, :failing
          create :que_job, :finished
          create :que_job, :expired

          http_login

          get :index
        end

        it 'renders page' do
          expect(response).to be_successful
        end
      end
    end
  end
end
