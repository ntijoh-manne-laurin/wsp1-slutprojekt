class App < Sinatra::Base

  def db
		return @db if @db

		@db = SQLite3::Database.new("db/data.sqlite")
		@db.results_as_hash = true

		return @db
	end

  get '/products' do
    @products = db.execute('SELECT * FROM products')
    erb(:"index")
  end

  get '/products/:category' do |category|
    @products = db.execute(
    'SELECT products.* FROM products
    INNER JOIN CategoryProducts
      ON products.id = CategoryProducts.product_id
    INNER JOIN categories
      ON categories.id = CategoryProducts.category_id
    WHERE categories.name=?', category)
    erb(:"index")
  end

end
