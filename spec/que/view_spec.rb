# frozen_string_literal: true

describe Que::View do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '#fetch_dashboard_stats' do
    before do
      create :que_job
      create :que_job, :failing
      create :que_job, :finished
      create :que_job, :expired
    end

    it 'returns dashboard stats' do
      expect(described_class.fetch_dashboard_stats[0]).to include(
        {
          total: 4,
          running: 0,
          scheduled: 1,
          failing: 1,
          finished: 1,
          expired: 1
        }
      )
    end
  end

  describe '#fetch_queue_metrics' do
    before do
      create :que_job
      create :que_job, :failing
      create :que_job, :finished
      create :que_job, :expired
    end

    it 'returns dashboard stats', :aggregate_failures do
      result = described_class.fetch_queue_metrics

      expect(result.keys).to eq [:default]
      expect(result[:default]).to include(
        {
          running: 0,
          scheduled: 1,
          failing: 1,
          finished: 1,
          expired: 1
        }
      )
    end
  end
end
