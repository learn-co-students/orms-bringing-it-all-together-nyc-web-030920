class Dog

    attr_accessor :name
    attr_reader :id, :breed

    def initialize(hash)
        @id = hash[:id]
        @name = hash[:name]
        @breed = hash[:breed]
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
    end



    def save
        if self.id
            sql = "UPDATE dogs SET name=?,breed=? WHERE id = ?"
            DB[:conn].execute(sql, self.name, self.breed, self.id)
            self
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        dog = self.new(id: id, name: name, breed: breed)
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, name).map do|row|
            self.new_from_db(row)
        end.first
    end
    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
              SELECT *
              FROM dogs
              WHERE name = ?
              AND breed = ?
              LIMIT 1
            SQL
    
        dog = DB[:conn].execute(sql,name,breed)
    
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog 
    end
end