namespace :qomo do

  desc 'QOMO | Setup new deployed app'
  task setup: :environment do
    Rake::Task['qomo:create_admin_user'].invoke
  end

  desc 'QOMO | Create default admin user'
  task create_admin_user: :environment do
    admin_user = User.new username: Config.admin.username,
                email: Config.admin.email,
                password: '11111111',
                password_confirmation: '11111111',
                confirmed_at: Time.now

    admin_user.confirm!
    admin_user.add_role :admin
    admin_user.save
  end

end
