require 'compass/sass_extensions/sprites/helpers/image_helper'
require 'compass/sass_extensions/sprites/helpers/processing_helper'
module Compass
  module SassExtensions
    module Sprites
      class Base < Sass::Script::Literal
        include ImageHelper
        include ProcessingHelper
        
        # Initialize a new aprite object from a relative file path
        # the path is relative to the <tt>images_path</tt> confguration option
        def self.from_uri(uri, context, kwargs)
          sprite_map = ::Compass::SpriteMap.new(:uri => uri.value, :options => {})
          sprites = sprite_map.files.map do |sprite|
            sprite.gsub(Compass.configuration.images_path+"/", "")
          end
          new(sprites, sprite_map, context, kwargs)
        end
        
        # Loads the sprite engine
        def require_engine!
          self.class.send(:include, eval("::Compass::SassExtensions::Sprites::#{modulize}Engine"))
        end
      
        # Changing this string will invalidate all previously generated sprite images.
        # We should do so only when the packing algorithm changes
        SPRITE_VERSION = "1"

        attr_accessor :image_names, :path, :name, :map, :kwargs
        attr_accessor :images, :width, :height


        def initialize(sprites, sprite_map, context, kwargs)
          require_engine!
          @image_names = sprites
          @path = sprite_map.path
          @name = sprite_map.name
          @kwargs = kwargs
          @kwargs['cleanup'] ||= Sass::Script::Bool.new(true)
          @kwargs['smart_pack'] ||= Sass::Script::Bool.new(false)
          @images = nil
          @width = nil
          @height = nil
          @evaluation_context = context
          @map = sprite_map
          validate!
          compute_image_metadata!
        end

       
      
        # Calculates the overal image dimensions
        # collects image sizes and input parameters for each sprite
        # Calculates the height
        def compute_image_metadata!
          @width = 0
          init_images
          compute_image_positions!
          @height = @images.last.top + @images.last.height
        end
        
        # Creates the Sprite::Image objects for each image and calculates the width
        def init_images
          @images = image_names.collect do |relative_file|
            image = Compass::SassExtensions::Sprites::Image.new(self, relative_file, kwargs)
            @width = [ @width, image.width + image.offset ].max
            image
          end
        end
        
        # Calculates the overal image dimensions
        # collects image sizes and input parameters for each sprite
        def compute_image_positions!
          if kwargs.get_var('smart-pack').value
            smart_packing
          else
            legacy_packing
          end
        end
        
        

        # Validates that the sprite_names are valid sass
        def validate!
          for sprite_name in sprite_names
            unless sprite_name =~ /\A#{Sass::SCSS::RX::IDENT}\Z/
              raise Sass::SyntaxError, "#{sprite_name} must be a legal css identifier"
            end
          end
        end

        # The on-the-disk filename of the sprite
        def filename
          File.join(Compass.configuration.images_path, "#{path}-#{uniqueness_hash}.png")
        end

        # Generate a sprite image if necessary
        def generate
          if generation_required?
            if kwargs.get_var('cleanup').value
              cleanup_old_sprites
            end
            sprite_data = construct_sprite
            save!(sprite_data)
            Compass.configuration.run_callback(:sprite_generated, sprite_data)
          end
        end
        
        def cleanup_old_sprites
          Dir[File.join(Compass.configuration.images_path, "#{path}-*.png")].each do |file|
            FileUtils.rm file
          end
        end
        
        # Does this sprite need to be generated
        def generation_required?
          !File.exists?(filename) || outdated?
        end

        # Returns the uniqueness hash for this sprite object
        def uniqueness_hash
          @uniqueness_hash ||= begin
            sum = Digest::MD5.new
            sum << SPRITE_VERSION
            sum << path
            images.each do |image|
              [:relative_file, :height, :width, :repeat, :spacing, :position, :digest].each do |attr|
                sum << image.send(attr).to_s
              end
            end
            sum.hexdigest[0...10]
          end
          @uniqueness_hash
        end

        # Saves the sprite engine
        def save!(output_png)
          saved = output_png.save filename
          Compass.configuration.run_callback(:sprite_saved, filename)
          saved
        end

        # All the full-path filenames involved in this sprite
        def image_filenames
          @images.map(&:file)
        end

        # Checks whether this sprite is outdated
        def outdated?
          if File.exists?(filename)
            return @images.map(&:mtime).any? { |imtime| imtime.to_i > self.mtime.to_i }
          end
          true
        end

        # Mtime of the sprite file
        def mtime
          @mtime ||= File.mtime(filename)
        end

        def inspect
          to_s
        end

        def to_s(kwargs = self.kwargs)
          sprite_url(self).value
        end

        def respond_to?(meth)
          super || @evaluation_context.respond_to?(meth)
        end

        def method_missing(meth, *args, &block)
          if @evaluation_context.respond_to?(meth)
            @evaluation_context.send(meth, *args, &block)
          else
            super
          end
        end
        
        private 
        
        def modulize
          @modulize ||= Compass::configuration.sprite_engine.to_s.scan(/([^_.]+)/).flatten.map {|chunk| "#{chunk[0].chr.upcase}#{chunk[1..-1]}" }.join
        end
        
      end
    end
  end
end
