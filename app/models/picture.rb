class Picture < ApplicationRecord
  # This model only exists for uploading images to be used as page content from the wysiwyg editor
  # TODO: instead of using an upload model, integrate more tightly with ActiveStorage's DirectUpload feature
  has_one_attached :file
  belongs_to :uploader, class_name: 'User'
end
