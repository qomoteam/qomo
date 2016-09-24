class JobUnit < ApplicationRecord

  include StatusAware

  belongs_to :job
  belongs_to :tool

  def out
    if self.docker
      Docker::Container.get(self.docker['cid'], {}, Docker::Connection.new(self.docker['host'], {})).logs(stdout: true, stderr: true)
    else
      ''
    end
  end

end
