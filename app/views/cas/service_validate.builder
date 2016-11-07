# encoding: UTF-8
xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
if @success
  xml.tag!("cas:serviceResponse", 'xmlns:cas' => "http://www.yale.edu/tp/cas") do
    xml.tag!("cas:authenticationSuccess") do
      xml.tag!("cas:user", @user.username)
      xml.tag!("cas:attributes") do
        @user.profile.attributes.each do |key, value|
          namespace_aware_key = key[0..3]=='cas:' ? key : 'cas:' + key
          xml.tag!(namespace_aware_key, value.to_s)
        end
      end
    end
  end
else
  xml.tag!("cas:serviceResponse", 'xmlns:cas' => "http://www.yale.edu/tp/cas") do
    xml.tag!("cas:authenticationFailure", {:code => 'INVALID_TICKET'}, 'Ticket not recognized')
  end
end
