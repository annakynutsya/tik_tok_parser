require 'csv'

class CsvFileService
  def generate_csv(data)
    CSV.open('data.csv', 'w+', write_headers: true,
             headers: [:Account, :Followers, :Avg_Views, :Channel_Desc, :Email, :Other_Accounts]) do |csv|
      data.each do |row|
        csv << row
      end
    end
  end
end
