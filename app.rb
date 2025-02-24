class App < Sinatra::Base

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/item.sqlite")
        @db.results_as_hash = true

        return @db
    end

    get '/' do
        redirect("/views")
    end

    get '/views' do
        @item_items = db.execute('SELECT * FROM item ORDER BY price ASC')
        @item_category = db.execute('SELECT DISTINCT category FROM item')
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

        db.execute("INSERT INTO item (name, description, category, price) VALUES(?,?,?,?)", [name, description, category, price])
        redirect("/views")
    end

    post '/views/:id/delete' do |id|
        #hämtar id och deletar i databas "item" där id matchar hämtade id
        db.execute("DELETE FROM item WHERE id=?", id)
        redirect("/views")
    end

    get '/item/:id' do |id|
        #hämtar id och deletar i databas "item" där id matchar hämtade id
        @item = db.execute('SELECT * FROM item WHERE id=?', id).first
        erb(:"item")
    end

    get '/category/:category' do |category|
        db.results_as_hash = true  # Se till att resultatet returneras som hash
        @items_by_category = db.execute('SELECT * FROM item WHERE category = ?', category)
    
        # Om inga objekt hittas, skicka en 404-sida
        halt 404, "Inga objekt hittades i denna kategori" if @items_by_category.empty?
    
        erb :category_list  # Kopplar till vyn
    end
    

    get '/views/landing' do
        @item_category = db.execute('SELECT category FROM item')
        erb(:"landing")
    end

    get '/views/:id/select' do
        @item_items = db.execute('SELECT * FROM item WHERE category=?', id)
        erb(:"landing")
    end

    

    

    
    
    

end



