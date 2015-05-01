namespace :tag_indexing do
  desc "default task"
  task :default, [:skip] => :environment do
    total = Tag.count - skip.to_i
    current = 0
    Tag.skip(skip.to_i).each do |t|
      TagIndexingWorker.perform_async(:index, t.id.to_s)
      current += 1
      puts "#{current}/#{total}" if (current % 1000) == 0
    end
  end
end

# current 4,259,505