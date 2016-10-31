class Admin::ToolsController < Admin::ApplicationController

  def audit
    @tools = Tool.where(audit: true)
  end

  def approve_audit
    tool = Tool.find params[:id]
    tool.shared = true
    tool.audit = false
    tool.save
    redirect_back fallback_location: audit_admin_tools_path
  end

  def decline_audit
    tool = Tool.find params[:id]
    tool.shared = false
    tool.audit = false
    tool.save
    redirect_back fallback_location: audit_admin_tools_path
  end

end
