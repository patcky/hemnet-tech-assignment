# frozen_string_literal: true

class Municipality < ApplicationRecord
  has_many :prices, dependent: :destroy
  has_many :packages, through: :prices

  validates :name, presence: true
end
