# frozen_string_literal: true

describe 'Jobs' do
  describe 'GET#index' do
    context 'without status' do
      before { get '/que-view/jobs' }

      it 'renders page' do
        expect(response).to render_template(:index)
      end
    end

    context 'with scheduled status' do
      before do
        create :que_job
        create :que_job, :with_positional_argument
        create :que_job, :with_keyword_argument
        create :que_job, :with_que_argument

        get '/que-view/jobs?status=scheduled'
      end

      it 'renders page' do
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET#show' do
    context 'for unexisting job' do
      it 'redirects to root page' do
        get '/que-view/jobs/0'

        follow_redirect!

        expect(response).to render_template('welcome/index')
      end
    end

    context 'for existing job' do
      let!(:que_job) { create :que_job }

      it 'renders page' do
        get "/que-view/jobs/#{que_job.id}"

        expect(response).to render_template(:show)
      end
    end
  end
end
