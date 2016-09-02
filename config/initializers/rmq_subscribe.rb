q = RMQ.channel.queue("qomo_#{Rails.env}.jobs.status", durable: true, exclusive: false, auto_delete: false)
q.subscribe do |delivery_info, metadata, payload|
  juid = payload
  job_unit = JobUnit.find(juid)
  uid = job_unit.job.user.id

  ActionCable.server.broadcast("job_manager_#{uid}", job_id: job_unit.job.id, job_unit_id: job_unit.id)

end
