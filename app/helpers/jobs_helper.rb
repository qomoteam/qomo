module JobsHelper

  def running_time(job)
    t = job.end? ? job.updated_at : Time.now
    distance_of_time_in_words(job.created_at, t)
  end

end
