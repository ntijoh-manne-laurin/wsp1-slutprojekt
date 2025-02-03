class App < Sinatra::Base

  def db
		return @db if @db

		@db = SQLite3::Database.new("db/data.sqlite")
		@db.results_as_hash = true

		return @db
	end

  get '/' do
    @products = db.execute('SELECT * FROM products')
    erb(:"index")
  end

end
