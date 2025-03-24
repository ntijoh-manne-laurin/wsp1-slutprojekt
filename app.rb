require 'securerandom'
require_relative 'models/user.rb'

class App < Sinatra::Base

  def db
		return @db if @db

		@db = SQLite3::Database.new("db/data.sqlite")
		@db.results_as_hash = true

		return @db
	end

  before do 
    @user = User.get_by_id(session[:user_id])
  end

  configure do
    enable :sessions
    set :session_secret, SecureRandom.hex(64)
  end

  get '/' do
    redirect('/products')
  end

  get '/products' do
    @products = db.execute('SELECT * FROM products')
    erb(:"products/index")
  end

  get '/products/:id' do |id|
    @products = db.execute('SELECT * FROM products WHERE id=?', id).first
    erb(:"products/show")
  end

  get '/products/category/:id' do |id|
    @products = db.execute(
    'SELECT products.* FROM products
    INNER JOIN CategoryProducts
      ON products.id = CategoryProducts.product_id
    INNER JOIN categories
      ON categories.id = CategoryProducts.category_id
    WHERE categories.id=?', id)
    erb(:"products/index")
  end


  get '/users/profile' do
    if !@user
      redirect('/users/login')
    else
      erb(:"/users/profile")
    end
  end

  get '/users/login' do
    erb(:"users/login")
  end

  post '/users/login' do
    name = params['username']
    cleartext_password = params['password']

    user = User.get_by_name(name)
    p user

    db_id = user["id"].to_i
    db_password_hashed = user["password"].to_s

    password_from_db = BCrypt::Password.new(db_password_hashed)

    #jämför lösenordet från databasen med det inmatade lösenordet
    if password_from_db == cleartext_password 
      p "rätt lösen"
      session[:user_id] = user['id']
      p user['id']
      p session[:user_id]
      redirect('/products')
    else
      status 401
      erb(:"login")
    end

  end

  get '/users/register' do
    erb(:"/users/register")
  end

  post '/users/register' do
    p params
    User.new(params[:username], params[:password])
    
    redirect('/users/login')
  end

end
