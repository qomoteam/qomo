namespace :qomo do

  desc 'QOMO | Setup new deployed app'
  task setup: :environment do
    Rake::Task['db:setup'].invoke
    Rake::Task['qomo:create_admin_user'].invoke
  end

  desc 'QOMO | Create default admin user'
  task create_admin_user: :environment do
    User.create username: Config.admin.username,
                email: Config.admin.email,
                admin: true,
                password: '11111111',
                password_confirmation: '11111111'
  end

end
