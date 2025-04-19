require 'securerandom'
require_relative 'models/product.rb'
require_relative 'models/user.rb'

class App < Sinatra::Base

  # def db
	# 	return @db if @db

	# 	@db = SQLite3::Database.new("db/data.sqlite")
	# 	@db.results_as_hash = true

	# 	return @db
	# end

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
    @products = Product.get
    erb(:"products/index")
  end

  get '/products/new' do
    if User.is_admin?(@user)
      erb(:"/products/new")
    end
  end

  post '/products/new' do
    if User.is_admin?(@user)
      p params
      Product.add(params['name'], params['price'].to_f, params['description'])
      redirect("/products")
    else
      p 'Error, requires admin permission'
      redirect('/')
    end
  end

  get '/products/:id' do |id|
    @products = Product.id_get(id)
    erb(:"products/show")
  end

  get '/products/category/:id' do |id|
    @products = Product.category(id)
    erb(:"products/index")
  end

  get '/products/:id/edit' do |id|
    @product = Product.id_get(id)
    if User.is_admin?(@user)
      erb(:"/products/edit")
    end
  end

  post '/products/:id/update' do |id|
    if User.is_admin?(@user)
      p params
      Product.update(id, params['name'], params['price'].to_f, params['description'])
      redirect("/products/#{id}")
    else
      p 'Error, requires admin permission'
      redirect('/')
    end
  end

  post '/products/:id/delete' do |id| 
    if User.is_admin?(@user)
      Product.destroy(id)
      redirect('/')
    else
      p 'Error, requires admin permission'
      redirect('/')
    end
  end

  get '/users' do
    if User.is_admin?(@user)
      @users = User.getall
      erb(:"/users/index")
    else
      redirect('/')
    end
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

  get '/users/logout' do
    p "Logging out"
    session.clear
    redirect('/')
  end

  get '/users/register' do
    erb(:"/users/register")
  end

  post '/users/register' do
    p params
    User.register(params[:username], params[:password])
    
    redirect('/users/login')
  end

  get '/users/new' do
    if User.is_admin?(@user)
      erb(:"/users/new")
    else
      p 'Error, requires admin permission'
      redirect('/')
    end
  end

  post '/users' do
    p params
    if User.is_admin?(@user)
      User.new(params[:username], params[:password], params[:user_type])
      redirect('/users')
    else
      p 'Error, requires admin permission'
      redirect('/')
    end
  end

  get '/users/:id/edit' do |id|
    @users = User.get_by_id(id)
    if User.is_admin?(@user)
      erb(:"/users/edit")
    else
      p 'Error, requires admin permission'
      redirect('/')
    end
  end

  post '/users/:id/update' do |id|
    if User.is_admin?(@user)
      p params
      User.update(id, params['username'], params['password'], params['type'])
      redirect("/users")
    else
      p 'Error, requires admin permission'
      redirect('/')
    end
  end

  post '/users/:id/delete' do |id|
    if User.is_admin?(@user)
      User.destroy(id)
      redirect('/')
    else
      p 'Error, requires admin permission'
      redirect('/')
    end
  end

end
