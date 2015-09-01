class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :setup_new

  def datastore
    Datastore.new self.id, Config.dir_users
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  private

  def setup_new
    datastore.create!
  end

end
