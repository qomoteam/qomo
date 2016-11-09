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

  before_create :ensure_profile_atttached

  after_create :setup_new

  after_destroy_commit :clean_datastore

  attr_accessor :login, :term_of_service

  has_many :filerecords, foreign_key: :owner_id, dependent: :destroy
  has_many :jobs, dependent: :destroy

  has_many :pipelines, -> {order 'created_at DESC'}, foreign_key: :owner_id
  has_many :tools, foreign_key: :owner_id

  has_one :profile, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :profile

  scope :expired_guests, -> {
    where 'username LIKE ? and CURRENT_DATE-current_sign_in_at>?', 'guest-%', '3 mons'
  }


  def datastore
    Datastore.new self.id, Config.dir_users
  end


  def job_engine
    JobEngine.new self.id, datastore
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


  protected

  def send_on_create_confirmation_instructions

  end


  private

  def ensure_profile_atttached
    self.profile ||= Profile.new
  end

  def setup_new
    datastore.create!
  end

  def clean_datastore
    FileUtils.rm_rf datastore.home
  end

end
