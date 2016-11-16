module JobsHelper

  def running_time(job)
    distance_of_time_in_words(job.created_at, job.ended_at || Time.now)
  end

end
