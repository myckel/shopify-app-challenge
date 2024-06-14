require 'open-uri'
class Snapshot < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :product_data, presence: true

  # Callbacks
  before_save :set_location, if: -> { location_id.blank? }
  before_save :download_images

  private

  def download_images
    product_data.each do |product|
      next unless product['images']

      product['converted_images'] ||= []

      current_images = product['images'].map do |image_url|
        begin
          {
            filename: File.basename(image_url).gsub(/\?.*/, ''),
            attachment: Base64.encode64(URI.open(image_url).read)
          }
        rescue OpenURI::HTTPError => e
          Rails.logger.error("Failed to download image from #{image_url}: #{e.message}")
          nil
        end
      end.compact

      # Preserve existing images if they were removed from the store
      product['converted_images'].each do |existing_image|
        unless current_images.any? { |new_image| new_image[:filename] == existing_image['filename'] }
          current_images << existing_image
        end
      end

      # Update the product with the merged images
      product['converted_images'] = current_images
    end
  end

  def set_location
    locations = ShopifyAPI::Location.all
    self.location_id = locations&.first&.id # Only for the challenge, set the first location assuming we have only one location
  end
end
