namespace :tag_stat do
  desc "default task"
  task default: :environment do
    Tag.each do |t|
      TagStatWorker.perform_async(t.name)
    end
  end
end
