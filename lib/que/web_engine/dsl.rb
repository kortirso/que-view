# frozen_string_literal: true

module Que
  module WebEngine
    class DSL
      def dashboard_stats(search)
        execute(
          dashboard_stats_sql(search)
        )
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
      # rubocop: enable Metrics/MethodLength

      def execute(sql)
        Que.execute(sql)
      end
    end
  end
end
