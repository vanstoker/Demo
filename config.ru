# cat config.ru
require "roda"
require "sequel"
require "pry"
require "json"

DB = Sequel.connect('sqlite://test.db') # memory database, requires sqlite3

class App < Roda
  plugin :all_verbs
  plugin :json
  plugin :json_parser
  #plugin :render        # Plugin for web visualisation.
  #plugin :view_options  # The same.

  route do |r|
    # GET / request
    r.root do
      # binding.pry
      r.redirect "/hello"
    end

    # /hello branch
    r.on "hello" do
      # Set variable for all routes in /hello branch
      @greeting = 'Hello'

      # GET /hello/world request
      r.get "world" do
       "#{@greeting} world!"
      end

      # /hello request
      r.is do
        # GET /hello request
        r.get do
          "#{@greeting}!"
        end

        # POST /hello request - - - - Why this route is't work?
        r.post do
          puts "Someone said #{@greeting}!"
          #r.redirect
        end
      end

      # GET /hello/users - - - - Why this route is't work?
      r.get "users" do        
        users = DB[:users]
        "#{users.first}"
      end
    end

# - - - - - - - - - - - - - - -
    
    r.on "users" do
      # POST /users
      r.post do
        id = DB[:users].insert(user: r.params["user_name"], password: r.params["password"])
        binding.pry
        "#{id}"
      end

      r.on Integer do |id|
        # GET /users/2 - Получить запись по id
        r.get do
          JSON.generate(DB[:users][id: id])
        end
        
        # UPDATE /users/2 - Изменение записи с указанным id
        r.put do
          DB[:users].where(id: id).update(user: r.params["user_name"], password: r.params["password"])
          JSON.generate(DB[:users][id: id])
        end

        # DELETE /users/2 - Удаление записи с указанным id
        r.delete do
          DB[:users].where(id: id).delete
          "Dataset whid ID: #{id} was deleted"
        end
      end
    end

    # GET /about
    r.get "about" do
      "About"
    end
# - - - - - - - - - - - - - -

    end
  end

run App.freeze.app