class App < Sinatra::Base

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todo.sqlite")
        @db.results_as_hash = true

        return @db
    end

    get '/' do
        redirect("/views")
    end

    get '/views' do
        @todo_items = db.execute('SELECT * FROM todo ORDER BY price ASC')
        @rate_items = db.execute('SELECT * FROM rate')
        erb(:"index")
    end



    # get '/views/new' do
    #     erb(:"/new")
    #     redirect("/views")
    # end

    post '/views/new' do

        name = params["item_name"]
        description = params["item_description"]
        category = params["item_category"]
        price = params["item_price"]

        db.execute("INSERT INTO todo (name, description, price) VALUES(?,?,?)", [name, description, price])
        redirect("/views")
    end

    post '/views/:id/delete' do |id|
        #hämtar id och deletar i databas "todo" där id matchar hämtade id
        db.execute("DELETE FROM todo WHERE id=?", id)
        redirect("/views")
    end
    
    # post '/views/:id/rate' do |id|
    #     #hämtar id och deletar i databas "todo" där id matchar hämtade id
    #     db.execute("INSERT INTO rated WHERE id=?", id)
    #     redirect("/views")
    # end
    

    

    
    
    

end



