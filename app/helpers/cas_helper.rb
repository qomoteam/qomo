module CasHelper
  def service
    params[:service]
  end


  def cas_request
    cas_request? ? 'true' : nil
  end

  def cas_request?
    request.path.starts_with?('/cas') || service.present? || params[:cas_request] == 'true'
  end

  def cas_params
    {cas_request: cas_request, service: service}
  end

end
