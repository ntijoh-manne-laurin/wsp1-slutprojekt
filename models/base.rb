class Basemodel
  def initialize
		@db = SQLite3::Database.new("db/data.sqlite")
		@db.results_as_hash = true
	end
end