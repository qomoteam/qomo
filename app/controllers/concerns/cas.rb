module Cas
  extend ActiveSupport::Concern

  included do

    include CasHelper

    prepend_before_action :before_login, :only => [:new]

    def before_login
      if params[:service] and user_signed_in?
        cas_login
      end
    end

  end

end
