module CasHelper
  def cas_request?
    request.path.starts_with? '/cas'
  end

  def service
    params[:service]
  end
end
