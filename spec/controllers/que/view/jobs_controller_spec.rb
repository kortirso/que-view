# frozen_string_literal: true

describe Que::View::JobsController do
  routes { Que::View::Engine.routes }

  describe 'GET#index' do
    it 'renders page' do
      get :index

      expect(response).to be_successful
    end
  end

  describe 'PATCH#update' do
    context 'for unexisting job' do
      it 'redirects to root_path' do
        patch :update, params: { id: 0 }

        expect(response).to redirect_to root_path
      end
    end

    context 'for existing job' do
      let!(:que_job) { create :que_job, run_at: 1.week.before, expired_at: 1.week.before }

      it 'redirects to root_path', :aggregate_failures do
        patch :update, params: { id: que_job.id }

        expect(que_job.reload.expired_at).to be_nil
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'POST#reschedule_all' do
    context 'for unexisting job' do
      it 'does not reschedule any job' do
        post :reschedule_all, params: { status: 'scheduled' }

        expect(response).to redirect_to jobs_path(status: 'scheduled')
      end
    end

    context 'for existing job' do
      let!(:scheduled_que_job) { create :que_job, run_at: nil }
      let!(:expired_que_job) { create :que_job, :expired }

      it 'reschedules jobs', :aggregate_failures do
        post :reschedule_all, params: { status: 'scheduled' }

        expect(scheduled_que_job.reload.run_at).not_to be_nil
        expect(expired_que_job.reload.expired_at).to be_nil
        expect(response).to redirect_to jobs_path(status: 'scheduled')
      end
    end
  end

  describe 'DELETE#destroy' do
    context 'for unexisting jobs' do
      it 'does not destroy any job', :aggregate_failures do
        expect { delete :destroy_all, params: { status: 'scheduled' } }.not_to change(QueJob, :count)
        expect(response).to redirect_to jobs_path(status: 'scheduled')
      end
    end

    context 'for existing jobs' do
      before do
        create :que_job
        create :que_job, :failing
      end

      it 'destroys jobs with specific status', :aggregate_failures do
        expect { delete :destroy_all, params: { status: 'scheduled' } }.to change(QueJob, :count).by(-1)
        expect(response).to redirect_to jobs_path(status: 'scheduled')
      end
    end
  end

  describe 'DELETE#destroy_all' do
    context 'with unexisting jobs' do
      it 'does not destroy any job', :aggregate_failures do
        expect { delete :destroy_all, params: { status: 'scheduled' } }.not_to change(QueJob, :count)
        expect(response).to redirect_to jobs_path(status: 'scheduled')
      end
    end

    context 'with existing jobs' do
      before do
        create :que_job
        create :que_job, :failing
      end

      it 'destroys jobs with specific status', :aggregate_failures do
        expect { delete :destroy_all, params: { status: 'scheduled' } }.to change(QueJob, :count).by(-1)
        expect(response).to redirect_to jobs_path(status: 'scheduled')
      end
    end
  end
end
