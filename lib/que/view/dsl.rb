# frozen_string_literal: true

module Que
  module View
    class DSL
      def dashboard_stats(...)
        execute(dashboard_stats_sql(...))
      end

      def failing_jobs(...)
        execute(failing_jobs_sql(...))
      end

      def delete_all_failing_jobs
        execute(delete_jobs_query(lock_all_failing_jobs_sql))
      end

      private

      # rubocop: disable Metrics/MethodLength
      def dashboard_stats_sql(search)
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

      def failing_jobs_sql(per_page, offset, search)
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

      def lock_all_failing_jobs_sql
        <<-SQL.squish
          SELECT id, pg_try_advisory_lock(id) AS locked
          FROM que_jobs
          WHERE error_count > 0
        SQL
      end
      # rubocop: enable Metrics/MethodLength

      def execute(sql)
        Que.execute(sql)
      end
    end
  end
end
