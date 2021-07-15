DB = Sequel.connect('sqlite://test.db')
Sequel::Model.plugin :timestamps
class User < Sequel::Model
  def validate
  	super
    binding.pry
  	errors.add(:user, 'Must be present') if !user || user.empty?
    errors.add(:user, 'Is already taken') if user && new? && User[{user: user}]
    errors.add(:password, 'Must be present') if !password || password.empty?
    errors.add(:password, 'Is not a valid password') unless password =~ /\w/ # regex: [0-9a-zA-Z_]
  end
end

# Validation