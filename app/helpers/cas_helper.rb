module CasHelper
  def service
    params[:service]
  end

  def cas_request?
    pp params[:cas_request]
    request.path.starts_with?('/cas') || service.present? || params[:cas_request] == 'true'
  end

end
