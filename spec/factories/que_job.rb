# frozen_string_literal: true

FactoryBot.define do
  factory :que_job, class: 'QueJob' do
    job_class { 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper' }
    job_schema_version { 2 }
    args {
      [
        {
          job_id: SecureRandom.uuid,
          locale: 'en',
          priority: nil,
          timezone: 'UTC',
          arguments: nil,
          job_class: 'SimpleJob',
          executions: 0,
          queue_name: 'default',
          enqueued_at: '2024-07-31T08:53:46.868379000Z',
          scheduled_at: nil,
          provider_job_id: nil,
          exception_executions: {}
        }
      ]
    }

    trait :failing do
      error_count { 1 }
    end

    trait :finished do
      finished_at { DateTime.now }
    end

    trait :expired do
      expired_at { DateTime.now }
    end

    trait :with_positional_argument do
      args {
        [
          {
            job_id: SecureRandom.uuid,
            locale: 'en',
            priority: nil,
            timezone: 'UTC',
            arguments: ['value'],
            job_class: 'SimpleJob',
            executions: 0,
            queue_name: 'default',
            enqueued_at: '2024-07-31T08:53:46.868379000Z',
            scheduled_at: nil,
            provider_job_id: nil,
            exception_executions: {}
          }
        ]
      }
    end

    trait :with_keyword_argument do
      args {
        [
          {
            job_id: SecureRandom.uuid,
            locale: 'en',
            priority: nil,
            timezone: 'UTC',
            arguments: [{ 'key' => 'value', '_aj_symbol_keys' => ['key'] }],
            job_class: 'SimpleJob',
            executions: 0,
            queue_name: 'default',
            enqueued_at: '2024-07-31T08:53:46.868379000Z',
            scheduled_at: nil,
            provider_job_id: nil,
            exception_executions: {}
          }
        ]
      }
    end

    trait :with_que_argument do
      job_class { 'SimpleQueJob' }
      args { ['value'] }
      kwargs { { id: 1 } }
    end
  end
end
