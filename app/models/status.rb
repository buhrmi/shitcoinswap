class Status < ApplicationRecord
  first_or_create! # Ensure we have a status record in the DB
end
