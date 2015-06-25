module OneboxApiDoc
  class ApplicationController < ActionController::Base

    def index
      base = OneboxApiDoc.base
      base.reload_document

      # set all versions
      @main_versions = base.main_versions

      # set all extension version
      # @extension_versions = base.extension_versions

      # set default version
      @default_version = base.default_version

      # set main app
      @main_app = base.main_app

      # set extension apps
      # @extensions = base.extension_apps

      # set current version
      if api_params[:version].present?
        @current_version = base.get_version(api_params[:version])
      else
        @current_version = @default_version
      end

      # set tags of version
      @tags = base.tags

      # set apis group by resource
      @apis_by_resources = base.apis_group_by_resources(@current_version)

      # set display api(s)
      @api = base.get_api(api_params)

      render nothing: true
    end

    private

    def api_params
      params.permit(:version, :resource_name, :action_name)
    end
  end
end
