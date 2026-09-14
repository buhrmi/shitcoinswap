require "open-uri"

class User < ApplicationRecord
  JSON_OPTIONS = {
    only: [ :id, :name, :handle, :bio, :socials ],
    include: {
      image: {}
    }
  }
  PRIVATE_JSON_OPTIONS = {
    only: JSON_OPTIONS[:only] + [ :email ],
    include: JSON_OPTIONS[:include]
  }

  has_secure_password

  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
  validates :password, length: { minimum: 8 }, allow_nil: true

  validates :handle,
    uniqueness: { case_sensitive: false },
    presence: true,
    length: { minimum: 3, maximum: 16 },
    format: { with: /\A[a-zA-Z0-9_]+\z/, message: "must be letters, numbers, and underscore" }

  validates :name,
    presence: true,
    length: { minimum: 1, maximum: 20 }

  validates :bio,
    length: { maximum: 160 },
    allow_nil: true

  has_one_attached :image

  has_many :identities, dependent: :destroy
  has_many :password_resets, dependent: :destroy
  has_many :wallets

  # Deposits (payments into the account, optionally funding an order)
  has_many :deposits, dependent: :destroy

  # Real-time per-currency balance (one row per [user, currency])
  has_many :balances, dependent: :destroy

  before_validation :set_basic_info, on: :create

  after_create :create_btc_balance

  syncs_to_dexie

  after_create_commit :send_welcome_email
  after_create_commit :fetch_image


  # Every user owns a vnd balance row (initially zero) so the UI always has a
  # row to render and syncs_to_dexie can push updates keyed by its id.
  def create_btc_balance
    balances.find_or_create_by!(asset_id: 1)
  end

  def as_json_for_dexie
    as_json(PRIVATE_JSON_OPTIONS)
  end

  private

  def set_basic_info
    ensure_unique_handle
    self.name ||= self.handle
  end

  def ensure_unique_handle
    if handle.present?
      # Sanitize: strip invalid chars, trim to max length
      self.handle = handle.gsub(/[^a-zA-Z0-9_]/, "")[0, 18]
    end

    # Generate a random handle if nil, blank, or too short after sanitization
    if handle.blank? || handle.length < 3
      self.handle = "user_#{SecureRandom.base58(4)}"
    end

    # Append random suffix until unique
    while User.exists?(handle: handle)
      base = handle[0, 14]
      self.handle = "#{base}_#{SecureRandom.base58(2)}"
    end
  end

  def fetch_image
    return if image.attached?

    identity = identities.find { |identity| identity.info["image"].present? }
    if identity
      ext = File.extname(identity.info["image"])
      image.attach(io: URI.open(identity.info["image"]), filename: "#{id}_profile#{ext}")
    elsif email.present?
      gravatar_id = Digest::MD5.hexdigest(email)
      url = "https://www.gravatar.com/avatar/#{gravatar_id}?s=200&d=mp"
      self.image.attach(io: URI.open(url), filename: "image.jpg")
    end
  end

  def send_welcome_email
    return unless email.present?

    UserMailer.welcome(self).deliver_later
  end
end
