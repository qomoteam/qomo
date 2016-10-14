class RMQ

  def publish(quename, message = {})
    x = channel.queue("qomo_#{Rails.env}.#{quename}", durable: true, exclusive: false, auto_delete: false)
    x.publish(message.to_json, content_type: 'application/json')
  end

  def channel
    @channel ||= connection.create_channel
  end

  def connection
    @connection ||= Bunny.new(host: Config.rmq.host, user: Config.rmq.user, pass: Config.rmq.pass, vhost: Config.rmq.vhost).tap do |c|
      c.start
    end
  end

  def subscribe!
    q = channel.queue("qomo_#{Rails.env}.jobs.status", durable: true, exclusive: false, auto_delete: false)
    q.subscribe do |delivery_info, metadata, payload|
      juid = payload
      job_unit = JobUnit.find(juid)
      uid = job_unit.job.user.id
      ActionCable.server.broadcast("job_manager_#{uid}", job_id: job_unit.job.id, job_unit_id: job_unit.id)
    end
  end

end
