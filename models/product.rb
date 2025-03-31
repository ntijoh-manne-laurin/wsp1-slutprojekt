class Product
  def self.db
		return @db if @db

		@db = SQLite3::Database.new("db/data.sqlite")
		@db.results_as_hash = true

		return @db
	end

  def self.get
    db.execute('SELECT * FROM products')
  end

  def self.id_get(id)
    db.execute('SELECT * FROM products WHERE id=?', id).first
  end

  def self.update(id, name, price, description)
    db.execute('UPDATE products SET name=?, price=?, description=? WHERE id=?', [name, price, description, id])
  end

end