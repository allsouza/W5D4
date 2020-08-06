# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint           not null, primary key
#  long_url   :string           not null
#  short_url  :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ShortenedUrl < ApplicationRecord
    validates :short_url, presence: true, uniqueness: true
    validates :long_url, presence: true, uniqueness: true
    validates :user_id, presence: true

    def self.random_code
        code = SecureRandom.urlsafe_base64(16)
        self.exists?(short_url: code) ? ShortenedUrl.random_code : code 
    end

    def self.create!(user, long_url) #User is an instance of the User class
        ShortenedUrl.create(short_url: ShortenedUrl.random_code, long_url: long_url, user_id: user.id).save
    end

    def num_clicks
        visits.count
    end

    def num_uniques
        visitors.count
    end

    def num_recent_uniques
        visitors.where('visits.updated_at >= ?', 10.minutes.ago).count
    end

    belongs_to :submitter,
        primary_key: :id,
        foreign_key: :user_id,
        class_name: :User

    has_many :visits,
        primary_key: :id,
        foreign_key: :shortened_url_id,
        class_name: :Visit

    has_many :visitors,
        Proc.new { distinct }, # -> {distinct}
        through: :visits,
        source: :user
end

