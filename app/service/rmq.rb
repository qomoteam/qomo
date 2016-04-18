class RMQ
  def self.publish(quename, message = {})
    x = channel.queue("qomo_#{Rails.env}.#{quename}", durable:true, exclusive: false, auto_delete: false)
    x.publish(message.to_json, content_type: 'application/json')
  end

  def self.channel
    @channel ||= connection.create_channel
  end

  def self.connection
    @connection ||= Bunny.new(host: Config.rmq.host, user: Config.rmq.user, pass: Config.rmq.pass, vhost: Config.rmq.vhost).tap do |c|
      c.start
    end
  end

end
