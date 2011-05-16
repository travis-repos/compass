module Compass
  module SassExtensions
    module Sprites
      class ImageRow
        attr_reader :images, :max_width
        
        def initialize(max_width)
          @images = []
          @max_width = max_width
        end
        
        def add(image)
          unless image.is_a?(Compass::SassExtensions::Sprites::Image)
            raise ArgumentError, "Must be a SpriteImage"
          end
          if (images.inject(0) {|sum, img| sum + img.width} + image.width) > max_width
            return false
          end
          @images << image
          true
        end
        
        def height
          images.map(&:height).max
        end
        
        def width
          images.map(&:width).max
        end
        
      end
    end
  end
end
  