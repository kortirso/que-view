# frozen_string_literal: true

module Que
  module View
    # rubocop: disable Metrics/ClassLength
    class DSL
      def fetch_dashboard_stats
        execute(fetch_dashboard_stats_sql)
      end

      def fetch_que_lockers
        execute(fetch_que_lockers_sql)
      end

      def fetch_queue_metrics
        execute(fetch_queue_metrics_sql).each_with_object({}) { |element, acc|
          acc[element[:queue_name].to_sym] ||= basis_queue_stats
          acc[element[:queue_name].to_sym][element[:status].to_sym] = element[:count_all]
        }
      end

      def fetch_queue_latencies(queue_names)
        queue_names.index_with { |queue_name| execute(fetch_queue_oldest_job_sql(queue_name)).dig(0, :enqueued_at) }
      end

      def fetch_queue_names
        execute(fetch_queue_names_sql).map { |queues_data|
          ["#{queues_data[:queue_name]} (#{queues_data[:count_all]})", queues_data[:queue_name]]
        }
      end

      def fetch_job_names(...)
        execute(fetch_job_names_sql(...)).map { |jobs_data|
          ["#{jobs_data[:job_name]} (#{jobs_data[:count_all]})", jobs_data[:job_name]]
        }
      end

      def fetch_running_jobs
        Que.job_states
      end

      def fetch_failing_jobs(...)
        execute(fetch_failing_jobs_sql(...))
      end

      def fetch_scheduled_jobs(...)
        execute(fetch_scheduled_jobs_sql(...))
      end

      def fetch_finished_jobs(...)
        execute(fetch_finished_jobs_sql(...))
      end

      def fetch_expired_jobs(...)
        execute(fetch_expired_jobs_sql(...))
      end

      def fetch_job(...)
        execute(fetch_job_sql(...))
      end

      def delete_failing_jobs
        execute(delete_jobs_sql(lock_failing_jobs_sql))
      end

      def delete_scheduled_jobs
        execute(delete_jobs_sql(lock_scheduled_jobs_sql))
      end

      def delete_job(...)
        execute(delete_jobs_sql(lock_job_sql(...)))
      end

      def reschedule_scheduled_jobs(time)
        execute(reschedule_jobs_sql(lock_scheduled_jobs_sql, time))
      end

      def reschedule_failing_jobs(time)
        execute(reschedule_jobs_sql(lock_failing_jobs_sql, time))
      end

      def reschedule_job(job_id, time)
        execute(reschedule_jobs_sql(lock_job_sql(job_id), time))
      end

      private

      def basis_queue_stats
        { scheduled: 0, failing: 0, running: 0, finished: 0, expired: 0 }
      end

      # rubocop: disable Metrics/MethodLength
      def fetch_dashboard_stats_sql
        <<-SQL.squish
          SELECT count(*) AS total,
                 count(locks.job_id) AS running,
                 coalesce(sum((error_count > 0 AND locks.job_id IS NULL AND expired_at IS NULL)::int), 0) AS failing,
                 coalesce(sum((error_count = 0 AND locks.job_id IS NULL)::int), 0) AS scheduled,
                 coalesce(sum((finished_at IS NOT NULL)::int), 0) AS finished,
                 coalesce(sum((expired_at IS NOT NULL)::int), 0) AS expired
          FROM que_jobs
          LEFT JOIN (
            SELECT (classid::bigint << 32) + objid::bigint AS job_id
            FROM pg_locks
            WHERE locktype = 'advisory'
          ) locks ON (que_jobs.id=locks.job_id)
        SQL
      end

      def fetch_que_lockers_sql
        <<-SQL.squish
          SELECT *
          FROM que_lockers
        SQL
      end

      def fetch_queue_metrics_sql
        <<-SQL.squish
          SELECT COUNT(*) AS count_all, queue AS queue_name,
            CASE
            WHEN expired_at IS NOT NULL THEN 'expired'
            WHEN finished_at IS NOT NULL THEN 'finished'
            WHEN locks.job_id IS NULL AND error_count > 0 AND expired_at IS NULL THEN 'failing'
            WHEN locks.job_id IS NULL AND error_count = 0 THEN 'scheduled'
            ELSE 'running'
            END status
          FROM que_jobs
          LEFT JOIN (
            SELECT (classid::bigint << 32) + objid::bigint AS job_id
            FROM pg_locks
            WHERE locktype = 'advisory'
          ) locks ON (que_jobs.id=locks.job_id)
          GROUP BY queue,
            CASE
            WHEN expired_at IS NOT NULL THEN 'expired'
            WHEN finished_at IS NOT NULL THEN 'finished'
            WHEN locks.job_id IS NULL AND error_count > 0 AND expired_at IS NULL THEN 'failing'
            WHEN locks.job_id IS NULL AND error_count = 0 THEN 'scheduled'
            ELSE 'running'
            END
        SQL
      end

      def fetch_queue_oldest_job_sql(queue_name)
        <<-SQL.squish
          SELECT args #>> '{0, enqueued_at}' AS enqueued_at
          FROM que_jobs
          WHERE queue = '#{queue_name}'
            AND expired_at IS NULL
            AND finished_at IS NULL
          ORDER BY args #>> '{0, enqueued_at}'
          LIMIT 1
        SQL
      end

      def fetch_queue_names_sql
        <<-SQL.squish
          SELECT COUNT(*) AS count_all, queue AS queue_name
          FROM que_jobs
          GROUP BY queue
        SQL
      end

      def fetch_job_names_sql(queue_name)
        <<-SQL.squish
          SELECT COUNT(*) AS count_all, args #>> '{0, job_class}' AS job_name
          FROM que_jobs
          #{queue_name.present? ? "WHERE queue = '#{queue_name}'" : ""}
          GROUP BY args #>> '{0, job_class}'
        SQL
      end

      def fetch_failing_jobs_sql(per_page, offset, params)
        where_condition = <<-SQL.squish
          WHERE locks.job_id IS NULL
            AND error_count > 0
            AND expired_at IS NULL
            #{search_condition(params)}
        SQL
        fetch_jobs_sql(per_page, offset, where_condition)
      end

      def fetch_scheduled_jobs_sql(per_page, offset, params)
        where_condition = <<-SQL.squish
          WHERE locks.job_id IS NULL
            AND error_count = 0
            #{search_condition(params)}
        SQL
        fetch_jobs_sql(per_page, offset, where_condition)
      end

      def fetch_finished_jobs_sql(per_page, offset, params)
        where_condition = <<-SQL.squish
          WHERE finished_at IS NOT NULL
            #{search_condition(params)}
        SQL
        fetch_jobs_sql(per_page, offset, where_condition)
      end

      def fetch_expired_jobs_sql(per_page, offset, params)
        where_condition = <<-SQL.squish
          WHERE expired_at IS NOT NULL
            #{search_condition(params)}
        SQL
        fetch_jobs_sql(per_page, offset, where_condition)
      end

      def search_condition(params)
        result = ''
        result += "AND queue = '#{params[:queue_name]}'" if params[:queue_name].present?
        result += "AND args #>> '{0, job_class}' = ('#{params[:job_name]}')" if params[:job_name].present?
        result
      end

      def fetch_jobs_sql(per_page, offset, where_condition)
        <<-SQL.squish
          SELECT que_jobs.*
          FROM que_jobs
          LEFT JOIN (
            SELECT (classid::bigint << 32) + objid::bigint AS job_id
            FROM pg_locks
            WHERE locktype = 'advisory'
          ) locks ON (que_jobs.id=locks.job_id)
          #{where_condition}
          ORDER BY run_at, id
          LIMIT #{per_page}::int
          OFFSET #{offset}::int
        SQL
      end

      def fetch_job_sql(job_id)
        <<-SQL.squish
          SELECT *
          FROM que_jobs
          WHERE id = #{job_id}::bigint
          LIMIT 1
        SQL
      end

      def delete_jobs_sql(scope)
        <<-SQL.squish
          WITH target AS (#{scope})
          DELETE FROM que_jobs
          USING target
          WHERE target.locked
          AND target.id = que_jobs.id
          RETURNING pg_advisory_unlock(target.id)
        SQL
      end

      def reschedule_jobs_sql(scope, time)
        <<-SQL.squish
          WITH target AS (#{scope})
          UPDATE que_jobs
          SET run_at = '#{time}'::timestamptz, expired_at = NULL
          FROM target
          WHERE target.locked
          AND target.id = que_jobs.id
          RETURNING pg_advisory_unlock(target.id)
        SQL
      end

      def lock_failing_jobs_sql
        <<-SQL.squish
          SELECT id, pg_try_advisory_lock(id) AS locked
          FROM que_jobs
          WHERE error_count > 0
        SQL
      end

      def lock_scheduled_jobs_sql
        <<-SQL.squish
          SELECT id, pg_try_advisory_lock(id) AS locked
          FROM que_jobs
          WHERE error_count = 0
        SQL
      end

      def lock_job_sql(job_id)
        <<-SQL.squish
          SELECT id, pg_try_advisory_lock(id) AS locked
          FROM que_jobs
          WHERE id = #{job_id}::bigint
        SQL
      end
      # rubocop: enable Metrics/MethodLength

      def execute(sql)
        Que.execute(sql)
      end
    end
    # rubocop: enable Metrics/ClassLength
  end
end
