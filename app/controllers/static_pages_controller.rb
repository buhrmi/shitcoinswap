class StaticPagesController < ApplicationController
  skip_before_action :require_user
  def login_email
  end
end
