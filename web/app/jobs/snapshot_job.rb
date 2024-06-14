class SnapshotJob
  include Sidekiq::Job

  def perform
    SnapshotService.new.create_snapshot
  end
end
