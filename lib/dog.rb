class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs (
            id INTEGER,
            name TEXT,
            breed TEXT
        );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(name:, breed:)
        new_dog = self.new(name: name, breed: breed)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        Dog.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
        dog_db = DB[:conn].execute(sql, id) [0]
        self.new_from_db(dog_db)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        dogs = DB[:conn].execute(sql, name, breed)
        if !dogs.empty?
            dog_data = dogs[0]
            dogs = new_from_db(dog_data)
        else
            dogs = create(name: name, breed: breed)
        end
        dogs
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        dog_name = DB[:conn].execute(sql, name) [0]
        self.new_from_db(dog_name)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end


end