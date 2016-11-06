class User < ApplicationRecord

  paginates_per 20

  acts_as_voter

  ratyrate_rater

  rolify

  validates_uniqueness_of :username, :email

  validates_acceptance_of :term_of_service, allow_nil: false, on: :create, message: 'must be accepted'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  after_create :setup_new

  attr_accessor :login, :term_of_service

  has_many :filerecords, foreign_key: :owner_id, dependent: :destroy
  has_many :jobs, dependent: :destroy

  has_many :pipelines, -> {order 'created_at DESC'}, foreign_key: :owner_id
  has_many :tools, foreign_key: :owner_id


  scope :expired_guests, -> {
    where 'username LIKE ? and CURRENT_DATE-current_sign_in_at>?', 'guest-%', '3 mons'
  }


  def destroy!
    self.destroy
    FileUtils.rm_rf datastore.home
  end


  def datastore
    Datastore.new self.id, Config.dir_users
  end


  def job_engine
    JobEngine.new self.id, datastore
  end


  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def displayed_name
    if full_name.blank?
      username
    else
      full_name
    end
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
    user.skip_confirmation!
    user.save
    user
  end

  private

  def setup_new
    datastore.create!
  end

end
