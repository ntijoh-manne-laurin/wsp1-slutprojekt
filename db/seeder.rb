require 'sqlite3'

class Seeder



  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS products')
    db.execute('DROP TABLE IF EXISTS categories')
    db.execute('DROP TABLE IF EXISTS CategoryProducts')
  end

  def self.create_tables
    db.execute('CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                password TEXT NOT NULL,
                type INTEGER NOT NULL)')

    db.execute('CREATE TABLE products (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                price FLOAT NOT NULL,
                description TEXT NOT NULL,
                owner_id INTEGER)')

    db.execute('CREATE TABLE categories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL)')

    db.execute('CREATE TABLE CategoryProducts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                category_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL)')
  end

  def self.populate_tables
    categories = ["Elektronik", "Hem & Trädgård", "Mode", "Skönhet", "Sport & Fritid",
    "Leksaker", "Livsmedel", "Hälsa", "Datorer & Tillbehör", "Bil & Motor"]
    categories.each { |cat| db.execute('INSERT INTO categories (name) VALUES (?)', cat)}

    db.execute('INSERT INTO products (name, price, description) VALUES (?,?,?)',["Mil Mi-26 transporthelikopter", 20, "Big choppa bombaclat."])
    db.execute('INSERT INTO products (name, price, description) VALUES (?,?,?)',["Fredde Fräs CNC", 3000, "Högteknologisk och avancerad cnc fräs i toppkvalitet."])

    products = JSON.parse(File.read('db/products.json'))
    products.each do |product|
      db.execute('INSERT INTO products (name, price, description) VALUES (?,?,?)', [product["name"], product["price"], product["description"]])
      product_id = db.execute('SELECT id FROM products WHERE name=?', product["name"]).first["id"]
      product["categories"].each do |category|
        category_id = db.execute('SELECT id FROM categories WHERE name=?', category).first["id"]
        p category_id
        p product_id
        p product["name"]
        db.execute('INSERT INTO CategoryProducts (category_id, product_id) VALUES (?,?)', [category_id, product_id])
      end
    end

    db.execute('INSERT INTO users (name, password, type) VALUES (?,?,?)', ["Mannecool1337", "Hemligt123", 2])

  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/data.sqlite')
    @db.results_as_hash = true
    @db
  end
end
