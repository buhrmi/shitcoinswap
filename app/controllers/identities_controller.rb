class IdentitiesController < ApplicationController
  def index
    @identities = current_user.identities
  end
end
