module Assetable
  module Base
    extend ActiveSupport::Concern
    
    included do
    end

    module ClassMethods
      def assetable *args
        if args.present?
          args.each do |arg|
            has_one :"#{arg}_association", -> { where(name: arg) }, class_name: "AssetAttachment", as: :assetable
            has_one arg, through: :"#{arg}_association", source: :asset
            accepts_nested_attributes_for :"#{arg}_association", allow_destroy: true
          end
        end
      end

      # Galleries
      def galleryable *args
        # By default, let's include a gallery. 
        unless args.include? :gallery
          has_one :gallery, as: :galleryable, dependent: :destroy
          accepts_nested_attributes_for :gallery
        end
        
        if args.present?
          args.each do |arg|
            has_one arg, -> { where(name: arg) }, class_name: "Gallery", as: :galleryable
            accepts_nested_attributes_for arg
          end
        end
      end
    end

    module InstanceMethods    
    end
  end
end

ActiveRecord::Base.send :include, Assetable::Base