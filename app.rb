require 'securerandom'
require_relative 'models/product.rb'
require_relative 'models/user.rb'
require_relative 'models/login.rb'

# @see Sinatra::Base
class App < Sinatra::Base

  before do 
    @user = User.get_by_id(session[:user_id])
  end

  configure do
    enable :sessions
    set :session_secret, SecureRandom.hex(64)
  end

# @!method GET /
# Omdirigerar till landningssidan
# @return [Redirect] Omdirigerar till /products
get '/' do
  redirect('/products')
end

# @!method GET /products
# Visar alla produkter
# @return [erb] HTML-sida med alla produkter
get '/products' do
  @products = Product.get
  erb(:"products/index")
end

# @!method GET /products/new
# Formulär för att skapa en ny produkt (adminkrav)
# @return [erb] Formulär för att skapa produkt
get '/products/new' do
  if User.is_admin?(@user)
    erb(:"/products/new")
  end
end

# @!method POST /products/new
# Skapar en ny produkt (endast admin)
# @param params [Hash] Formulärdata
# @option params [String] 'name' Namn på produkten
# @option params [Float] 'price' Pris på produkten
# @option params [String] 'description' Produktbeskrivning
# @return [Redirect] Omdirigerar till produktlistan
post '/products/new' do
  if User.is_admin?(@user)
    Product.add(params['name'], params['price'].to_f, params['description'])
    redirect("/products")
  else
    redirect('/')
  end
end

# @!method GET /products/:id
# Visar en specifik produkt
# @param [String] 'id' Produktens ID
# @return [erb] HTML-sida med produktinfo
get '/products/:id' do |id|
  @products = Product.id_get(id)
  erb(:"products/show")
end

# @!method GET /products/category/:id
# Visar produkter i en viss kategori
# @param [String] id Kategorins ID
# @return [erb] HTML-sida med produkter i kategori
get '/products/category/:id' do |id|
  @products = Product.category(id)
  erb(:"products/index")
end

# @!method GET /products/:id/edit
# Formulär för att redigera en produkt (adminkrav)
# @param [String] id Produktens ID
# @return [erb] Formulärsida för redigering
get '/products/:id/edit' do |id|
  @product = Product.id_get(id)
  if User.is_admin?(@user)
    erb(:"/products/edit")
  end
end

# @!method POST /products/:id/update
# Uppdaterar en produkt (adminkrav)
# @param [String] id Produktens ID
# @param params [Hash] Formulärdata
# @option params [String] 'name' Namn på produkten
# @option params [Float] 'price' Pris på produkten
# @option params [String] 'description' Beskrivning
# @return [Redirect] Omdirigerar till produktsidan
post '/products/:id/update' do |id|
  if User.is_admin?(@user)
    Product.update(id, params['name'], params['price'].to_f, params['description'])
    redirect("/products/#{id}")
  else
    redirect('/')
  end
end

# @!method POST /products/:id/delete
# Tar bort en produkt (adminkrav)
# @param [String] id Produktens ID
# @return [Redirect] Omdirigerar till startsidan
post '/products/:id/delete' do |id| 
  if User.is_admin?(@user)
    Product.destroy(id)
    redirect('/')
  else
    redirect('/')
  end
end

# @!method GET /users
# Visar alla användare (endast admin)
# @return [erb] HTML-sida med användarlista
get '/users' do
  if User.is_admin?(@user)
    @users = User.getall
    erb(:"/users/index")
  else
    redirect('/')
  end
end

# @!method GET /users/profile
# Visar användarens egen profil
# @return [erb, Redirect] HTML-sida med profil eller omdirigering till inloggning
get '/users/profile' do
  if !@user
    redirect('/users/login')
  else
    erb(:"/users/profile")
  end
end

# @!method GET /users/login
# Visar inloggningsformulär
# @return [erb] Inloggningsformulär
get '/users/login' do
  erb(:"users/login")
end

# @!method POST /users/login
# Loggar in användare
# @param params [Hash] Formulärdata
# @option params [String] 'username' Användarnamn
# @option params [String] 'password' Lösenord
# @return [Redirect, erb] Redirect vid lyckad inloggning eller login-sida vid fel
post '/users/login' do

  ip = request.ip
  Login.log(ip)

  if Login.safe?(ip)
    name = params['username']
    cleartext_password = params['password']
    user = User.get_by_name(name)

    db_password_hashed = user["password"].to_s
    password_from_db = BCrypt::Password.new(db_password_hashed)

    if password_from_db == cleartext_password 
      session[:user_id] = user['id']
      redirect('/products')
    else
      status 401
      erb(:"login")
    end
  else 
    status 401
    erb(:"login")
  end
end

# @!method GET /users/logout
# Loggar ut användare
# @return [Redirect] Omdirigerar till startsidan
get '/users/logout' do
  session.clear
  redirect('/')
end

# @!method GET /users/register
# Visar registreringsformulär
# @return [erb] Registreringsformulär
get '/users/register' do
  erb(:"/users/register")
end

# @!method POST /users/register
# Skapar nytt konto
# @param params [Hash] Formulärdata
# @option params [String] 'username' Användarnamn
# @option params [String] 'password' Lösenord
# @return [Redirect] Omdirigerar till login
post '/users/register' do
  User.register(params[:username], params[:password])
  redirect('/users/login')
end

# @!method GET /users/new
# Formulär för att skapa ny användare (endast admin)
# @return [erb, Redirect] Formulär eller omdirigering
get '/users/new' do
  if User.is_admin?(@user)
    erb(:"/users/new")
  else
    redirect('/')
  end
end

# @!method POST /users
# Skapar en ny användare (endast admin)
# @param params [Hash] Formulärdata
# @option params [String] 'username' Användarnamn
# @option params [String] 'password' Lösenord
# @option params [String] 'user_type' Typ av användare (admin/user)
# @return [Redirect] Omdirigerar till användarlistan
post '/users' do
  if User.is_admin?(@user)
    User.new(params[:username], params[:password], params[:user_type])
    redirect('/users')
  else
    redirect('/')
  end
end

# @!method GET /users/:id/edit
# Formulär för att redigera en användare (endast admin)
# @param [String] id Användarens ID
# @return [erb, Redirect] Formulär eller omdirigering
get '/users/:id/edit' do |id|
  @users = User.get_by_id(id)
  if User.is_admin?(@user)
    erb(:"/users/edit")
  else
    redirect('/')
  end
end

# @!method POST /users/:id/update
# Uppdaterar ett användarkonto (endast admin)
# @param [String] id Användarens ID
# @param params [Hash] Formulärdata
# @option params [String] 'username' Användarnamn
# @option params [String] 'password' Lösenord
# @option params [String] 'type' Typ av användare
# @return [Redirect] Omdirigerar till användarlistan
post '/users/:id/update' do |id|
  if User.is_admin?(@user)
    User.update(id, params['username'], params['password'], params['type'])
    redirect("/users")
  else
    redirect('/')
  end
end

# @!method POST /users/:id/delete
# Tar bort ett användarkonto (endast admin)
# @param [String] id Användarens ID
# @return [Redirect] Omdirigerar till startsidan
post '/users/:id/delete' do |id|
  if User.is_admin?(@user)
    User.destroy(id)
    redirect('/')
  else
    redirect('/')
  end
end


end
