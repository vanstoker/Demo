# cat config.ru
require "roda"
require "sequel"
require "pry"
require "json"
require "time"
require './user.rb'

# DB = Sequel.connect('sqlite://test.db') # Перенесли в user.rb (Модель)

class App < Roda
  plugin :all_verbs
  plugin :json
  plugin :json_parser
  plugin :render          # Plugin for web visualisation.
  plugin :view_options    # The same.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  route do |r|
    r.on "users" do
     
      # POST /users
      r.post do
        user = User.new(r.params)
        if user.valid?
          user.save
          r.redirect "/users/#{user.id}"
        else
          render("new", locals: {errors: user.errors})
        end
      end

      r.get "new" do
        render("new", locals: {errors: nil})
      end

      r.on Integer do |id|
         # GET /users/2 - Получить запись по id
         r.get do
           user = User.find(id: id)
           JSON.generate(user.to_hash)
           render("users", locals: {user: user})
         end
        
      # GET form to update /users//update/2 - Для ввода обновленных данных
      r.get "update" do
        "Fine"
      end

      # UPDATE /users/2 - Изменение записи с указанным id
      r.put do       
        user = User.find(id: id)
        user.set(r.params)
        if user.valid?
          user.save
          r.redirect "/users/#{user.id}"
        else
          render("new", locals: {errors: user.errors})
        end
        # JSON.generate(user.to_hash)
      end

      # DELETE /users/2 - Удаление записи с указанным id
      r.delete do
        user = User.find(id: id).delete
        "Dataset whid ID: #{id} was deleted"
      end
    end
  end
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  end
end

run App.freeze.app