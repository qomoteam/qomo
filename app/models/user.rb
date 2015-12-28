class User < ActiveRecord::Base

  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :setup_new

  attr_accessor :login

  has_many :jobs
  has_many :pipelines, foreign_key: :owner_id
  has_many :tools, foreign_key: :owner_id

  def datastore
    Datastore.new self.id, Config.dir_users
  end


  def job_engine
    JobEngine.new self.id, datastore
  end


  def full_name
    "#{self.first_name} #{self.last_name}"
  end


  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    if login
      where(conditions).where(['lower(username) = :value OR lower(email) = :value', { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end


  def self.create_guest
    x = SecureRandom.uuid
    username = "guest-#{x}"
    password = '123456'
    user = User.new username: username,
                    email: "#{username}@example.com",
                    first_name: 'Guest',
                    password: password, password_confirmation: password,
                    timezone: 'Beijing'
    user.add_role :guest
    user.save
    user
  end

  private

  def setup_new
    datastore.create!
  end

end
