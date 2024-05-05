# frozen_string_literal: true

class Municipality < ApplicationRecord
  has_many :prices, dependent: :destroy
  has_and_belongs_to_many :packages, join_table: :prices

  before_save :lowercase_name

  validates :name, presence: true, uniqueness: true

  private
    def lowercase_name
      self.name = name.downcase
    end
end
