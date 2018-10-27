class PicturesController < ApplicationController
  def create
    file = params[:file].try(:first)
    return unless file.present?

    upload = Picture.create! :file => file, :uploader_id => current_user.id

    render :json => {
      :file => {
        :url => url_for(upload.file),
        :id => upload.id
      }
    }
  end

  def index
    files = current_user.pictures.limit(10).order('created_at DESC')
    json = files.map do |upload|
    {
      :thumb => url_for(upload.file.variant(resize: '100x100')),
      :url => url_for(upload.file),
      :id => upload.id
    }
    end

    # TODO: use jbuilder
    render :json => json
  end

end
