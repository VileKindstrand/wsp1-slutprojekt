require 'bcrypt'

class App < Sinatra::Base

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/item.sqlite")
        @db.results_as_hash = true

        return @db
    end

    configure do
        enable :sessions
        set :session_secret, SecureRandom.hex(64)
        end



    helpers do
        def current_user
            db.execute('SELECT * FROM user WHERE id=?', [session[:user_id]]).first || 
            db.execute('SELECT * FROM user WHERE id=?', [1]).first
        end
    end

    helpers do
        def owns_cart_item?(cart_id)
          item = db.execute("SELECT * FROM cart WHERE id = ?", cart_id).first
          item && item["user_id"] == current_user["id"]

          
        end
    end


    before do
        @user = current_user

    end

    before '/admin' do


        if session[:user_type] == "admin"

        else
            redirect '/views'
        end

    end



    ##############################################################################################################
    ##############################################################################################################
    ##############################################################################################################

    get '/' do
        redirect("/views")
    end

    get '/admin' do
        @item_items = db.execute('SELECT * FROM item ORDER BY price ASC')
        @item_category = db.execute('SELECT DISTINCT category FROM item')

        erb(:"admin/index")
    end

    get '/views' do
        @item_items = db.execute('SELECT * FROM item ORDER BY price ASC')
        @item_category = db.execute('SELECT DISTINCT category FROM item')

        erb(:"shop/index")
    end


    post '/admin/new' do

        name = params["item_name"]
        description = params["item_description"]
        category = params["item_category"]
        price = params["item_price"]

        db.execute("INSERT INTO item (name, description, category, price) VALUES(?,?,?,?)", [name, description, category, price])
        redirect("/admin")
    end

    


    get '/user/signin' do
        erb(:"user/signin")
    end

    get '/user/login' do
        erb(:"user/login")
    end

    post '/views/login' do

        request_username = params[:username]
        request_plain_password = params[:password]
        user = db.execute("SELECT * FROM user 
                             WHERE username = ?", request_username).first

        db_id = user["id"].to_i
        db_type = user["type"].to_s

        db_password_hashed = user["password"].to_s
        bcrypt_db_password = BCrypt::Password.new(db_password_hashed)

        if bcrypt_db_password == request_plain_password

            session[:user_id] = db_id
            session[:user_type] = db_type


            if session[:user_type] == "admin"
                redirect '/admin'
            else
                redirect '/views'
            end
            
        else

            status 401
            redirect '/loginfailed'

        end
          
    end

    post '/views/signin' do

        username = params["username"]
        email = params["email"]
        password_hashed = BCrypt::Password.create(params["password"])
        type = params["type"]

        db.execute("INSERT INTO user (username, email, password, type) VALUES(?,?,?,?)", [username, email, password_hashed, type])
        redirect("/views")
    end

    post '/admin/:id/delete' do |id|

        db.execute("DELETE FROM item WHERE id=?", id)
        redirect("/admin")
    end

    post '/views/:id/add' do |id|

        item_id = id
        user_id = session[:user_id]

        #hämtar id och deletar i databas "item" där id matchar hämtade id
        db.execute("INSERT INTO cart (user_id, item_id) VALUES(?,?)", [user_id, item_id])
        redirect("/views")
    end

    get '/cart/index' do
        user_id = session[:user_id]
        #hämtar id och deletar i databas "item" där id matchar hämtade id
        @cart_items = db.execute("
        SELECT cart.id AS cart_id, item.* 
        FROM cart 
        JOIN item ON cart.item_id = item.id 
        WHERE cart.user_id = ?", user_id)
        erb(:"cart/index")
    end

    post '/cart/:cart_id/delete' do |cart_id|

        if  owns_cart_item?(cart_id)
            db.execute("DELETE FROM cart WHERE id = ?", cart_id)
            redirect '/cart'

        else
            redirect '/views'

        end
    end



    get '/items/:id' do |id|
        #hämtar id och deletar i databas "item" där id matchar hämtade id
        @item = db.execute('SELECT * FROM item WHERE id=?', id).first
        erb(:"items/show")
    end

    get '/shop/category/:category' do |category|
        db.results_as_hash = true  # Se till att resultatet returneras som hash
        @items_by_category = db.execute('SELECT * FROM item WHERE category = ?', category)
    
        # Om inga objekt hittas, skicka en 404-sida
        halt 404, "Inga objekt hittades i denna kategori" if @items_by_category.empty?
    
        erb(:"shop/category_list")  # Kopplar till vyn
    end

    get '/admin/:id/edit' do | id |
        @item = db.execute('SELECT * FROM item  WHERE id=?', id).first
        erb(:"admin/edit")
    end

    post '/views/:id/update' do | id |
        name = params["item_name"]
        description = params["item_description"]
        price = params["item_price"]
        category = params["item_category"]

        db.execute("UPDATE item SET name = ?, description = ?, price = ?, category = ? WHERE id = ?", [name, description, price, category, id])

        redirect "/admin"
    end

end



