class JobUnit < ApplicationRecord

  include StatusAware

  belongs_to :job
  belongs_to :tool

  def out
    Docker::Container.get(self.docker.cid, {}, Docker::Connection.new(self.docker.host, {})).logs
  end

end
