require 'mysql2'
require 'pg'
require 'openssl'
require 'base64'
require 'bcrypt'
require 'countries'

gsa_host = ARGV[0]
gsa_port = ARGV[1]
gsa_username = ARGV[2]
gsa_password = ARGV[3]
gsa_db = ARGV[4]
PASSKEY = ARGV[5]
SALT = ARGV[6]
ITERATIONS = ARGV[7].to_i

q_host = ARGV[8]
q_username = ARGV[9]
q_password = ARGV[10]
q_db = ARGV[11]

def decrypted(hashed)
  cipher = OpenSSL::Cipher::Cipher.new('DES')
  base_64_code = Base64.decode64(hashed)
  cipher.decrypt
  cipher.pkcs5_keyivgen PASSKEY, SALT, ITERATIONS, 'MD5'

  decrypted = cipher.update base_64_code
  decrypted << cipher.final
  decrypted
end

def encrypt(password)
  ::BCrypt::Password.create(password, cost: 10).to_s
end

q_con = PG.connect host: q_host, user: q_username, password: q_password, dbname: q_db

gsa_con = Mysql2::Client.new(host: gsa_host, port: gsa_port, username: gsa_username, password: gsa_password, database: gsa_db)

gsa_con.query("SELECT * FROM user where is_deleted!=1 AND is_active=1").each do |user|
  encrypted_password = encrypt(decrypted(user['password']))
  email = user['email']
  username = email.split('@')[0]

  if q_con.exec_params('SELECT count(*) as c FROM users where username=$1 OR email=$2', [username, email])[0]['c'].to_i > 0
    puts "#{user['user_id']}\t#{username}\t#{email}"
    next
  end
  created_at = user['create_time']
  country = ISO3166::Country.find_country_by_alpha3(gsa_con.query("SELECT * FROM country WHERE country_id='#{user['country_id']}'").first['ISO_ALPHA-3_code']).alpha2
  uid = q_con.exec_params('INSERT INTO users (username,email,encrypted_password,confirmed_at,created_at,updated_at) VALUES ($1,$2,$3,$4,$5,$6) RETURNING id', [username, email, encrypted_password, Time.now, created_at, Time.now])[0]['id']

  q_con.exec_params('INSERT INTO profiles (user_id,state,street,postal_code,phone,fax,lab,mid_name,reseach_area,city,department,first_name,last_name,organization,title,created_at,updated_at,country) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)',
                    [uid, user['state'], user['street'], user['postal_code'], user['phone'], user['fax'], user['lab'], user['mid_name'], user['reseach_area'],
                     user['city'], user['department'], user['first_name'], user['last_name'], user['organization'], user['title'], created_at, Time.now, country])

end

