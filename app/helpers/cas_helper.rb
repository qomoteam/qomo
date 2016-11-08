module CasHelper
  def service
    params[:service]
  end

  def cas_request?
    request.path.starts_with?('/cas') || service.present?
  end

end
