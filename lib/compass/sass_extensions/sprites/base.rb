module Compass
  module SassExtensions
    module Sprites
      class Base < Sass::Script::Literal
        
        attr_accessor :image_names, :path, :name, :map, :kwargs
        attr_accessor :images, :width, :height
        
        include Sprite
        include Processing
        include ImageHelper
        
        # Initialize a new aprite object from a relative file path
        # the path is relative to the <tt>images_path</tt> confguration option
        def self.from_uri(uri, context, kwargs)
          sprite_map = ::Compass::SpriteMap.new(:uri => uri.value, :options => {})
          sprites = sprite_map.files.map do |sprite|
            sprite.gsub(Compass.configuration.images_path+"/", "")
          end
          new(sprites, sprite_map, context, kwargs)
        end
        
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
        
        # Loads the sprite engine
        def require_engine!
          self.class.send(:include, eval("::Compass::SassExtensions::Sprites::#{modulize}Engine"))
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
