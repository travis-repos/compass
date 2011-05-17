module Compass
  module SassExtensions
    module Sprites
      module Processing
        def smart_packing
          fitter = ::Compass::SassExtensions::Sprites::RowFitter.new(@images)

          current_y = 0
          fitter.fit!.each do |row|
            current_x = 0
            row.images.each_with_index do |image, index|
              image.left = current_x
              image.top = current_y
              current_x += image.width
              image.left = image.position.unit_str == "%" ? (@width - image.width) * (image.position.value / 100) : image.position.value
            end
            current_y += row.height
          end
        end
        
        
        def legacy_packing
          @images.each_with_index do |image, index|
            image.left = image.position.unit_str == "%" ? (@width - image.width) * (image.position.value / 100) : image.position.value
            next if index == 0
            last_image = @images[index-1]
            image.top = last_image.top + last_image.height + [image.spacing,  last_image.spacing].max
            last_image = image
          end
        end
      end
    end
  end
end