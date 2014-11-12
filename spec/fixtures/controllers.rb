class TestController < ActionController::Base
  include Rails.application.routes.url_helpers

  def render(*attributes); end
end

class ApivoresController < TestController

  def swagger_doc
    ""
  end

end