# frozen_string_literal: true

describe Que::View::QueueMetricsController do
  routes { Que::View::Engine.routes }

  describe 'GET#index' do
    context 'without authorization' do
      before do
        create :que_job
        create :que_job, :failing
        create :que_job, :finished
        create :que_job, :expired

        get :index
      end

      it 'renders page' do
        expect(response).to be_successful
      end
    end
  end
end
