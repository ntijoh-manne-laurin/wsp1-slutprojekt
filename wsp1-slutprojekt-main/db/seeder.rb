require 'sqlite3'

class Seeder



  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS products')
  end

  def self.create_tables
    # db.execute('CREATE TABLE users (
    #             id INTEGER PRIMARY KEY AUTOINCREMENT,
    #             name TEXT NOT NULL,
    #             password TEXT NOT NULL,
    #             is_admin BOOLEAN NOT NULL)')

    db.execute('CREATE TABLE products (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                price FLOAT NOT NULL,
                description TEXT NOT NULL,
                owner_id INTEGER)')
  end

  def self.populate_tables
    db.execute('INSERT INTO products (name, price, description) VALUES (?,?,?)',["Mil Mi-26 transporthelikopter", 20, "Big choppa bombaclat."])
    db.execute('INSERT INTO products (name, price, description) VALUES (?,?,?)',["Fredde Fräs CNC", 3000, "Högteknologisk och avancerad cnc fräs i toppkvalitet."])
  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/data.sqlite')
    @db.results_as_hash = true
    @db
  end
end
