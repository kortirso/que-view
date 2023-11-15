# frozen_string_literal: true

module Que
  module View
    # rubocop: disable Metrics/ClassLength
    class DSL
      def fetch_dashboard_stats(...)
        execute(fetch_dashboard_stats_sql(...))
      end

      def fetch_failing_jobs(...)
        execute(fetch_failing_jobs_sql(...))
      end

      def fetch_scheduled_jobs(...)
        execute(fetch_scheduled_jobs_sql(...))
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

      # rubocop: disable Metrics/MethodLength
      def fetch_dashboard_stats_sql(search)
        <<-SQL.squish
          SELECT count(*)                    AS total,
                 count(locks.job_id)         AS running,
                 coalesce(sum((error_count > 0 AND locks.job_id IS NULL)::int), 0) AS failing,
                 coalesce(sum((error_count = 0 AND locks.job_id IS NULL)::int), 0) AS scheduled
          FROM que_jobs
          LEFT JOIN (
            SELECT (classid::bigint << 32) + objid::bigint AS job_id
            FROM pg_locks
            WHERE locktype = 'advisory'
          ) locks ON (que_jobs.id=locks.job_id)
          WHERE
            job_class ILIKE ('#{search}')
            OR que_jobs.args #>> '{0, job_class}' ILIKE ('#{search}')
        SQL
      end

      def fetch_failing_jobs_sql(per_page, offset, search)
        <<-SQL.squish
          SELECT que_jobs.*
          FROM que_jobs
          LEFT JOIN (
            SELECT (classid::bigint << 32) + objid::bigint AS job_id
            FROM pg_locks
            WHERE locktype = 'advisory'
          ) locks ON (que_jobs.id=locks.job_id)
          WHERE locks.job_id IS NULL
            AND error_count > 0
            AND (
              job_class ILIKE ('#{search}')
              OR que_jobs.args #>> '{0, job_class}' ILIKE ('#{search}')
            )
          ORDER BY run_at, id
          LIMIT #{per_page}::int
          OFFSET #{offset}::int
        SQL
      end

      def fetch_scheduled_jobs_sql(per_page, offset, search)
        <<-SQL.squish
          SELECT que_jobs.*
          FROM que_jobs
          LEFT JOIN (
            SELECT (classid::bigint << 32) + objid::bigint AS job_id
            FROM pg_locks
            WHERE locktype = 'advisory'
          ) locks ON (que_jobs.id=locks.job_id)
          WHERE locks.job_id IS NULL
            AND error_count = 0
            AND (
              job_class ILIKE ('#{search}')
              OR que_jobs.args #>> '{0, job_class}' ILIKE ('#{search}')
            )
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
