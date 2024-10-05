class FileGenerator
  def self.generate_filename(model)
    Rails.root.join("tmp/csv/#{model.public_send(:table_name)}_#{Date.zone.today.to_s}.csv")
  end
end

class UserDataGenerator
  def generate
    CSV.open(file_name, "wb", write_headers: true, headers: ['id','email', 'notifications.count']) do |csv|
      User.all.in_batches { |row| csv << [row.id, row.email, row.notifications_count] }
    end
  end

  private

  def file_name
    @file_name ||= FileGenerator.generate_filename(User)
  end
end
