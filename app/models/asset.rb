class Asset < ApplicationRecord
  JSON_OPTIONS = {
    only: [ :id, :name, :type ]
  }

  belongs_to :network

  has_many :wallets, dependent: :destroy
  has_many :deposits, dependent: :destroy
end
