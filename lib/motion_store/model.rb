module MotionStore
  class Model < NSManagedObject
    def save
      Store.shared.save
    end

    def remove
      Store.shared.remove(self)
    end

    class << self
      attr_reader :entity

      def class_name
        self.to_s
      end

      def method_missing(method, *args)
        # TODO: define_methodがサポートされたらリファクタリング
        unless MotionStore::ATTR_TYPES[method].nil?
          field(args[0], method, args[1])
        else
          case method
          when :relation
            relation(args[0], args[1])
          else
            super
          end
        end
      end

      def fields
        yield
        activate!
      end

      def field(name, type, options)
        options ||= {}
        (@properties ||= []) << NSAttributeDescription.new.tap do |prop|
          prop.name = name
          prop.attributeType = MotionStore::ATTR_TYPES[type]
          prop.indexed = options[:indexed] unless options[:indexed].nil?
          prop.transient = options[:transient] unless options[:transient].nil?
          prop.optional = !options[:required] unless options[:required].nil?
          unless options[:default].nil?
            if options[:default].respond_to?(:call)
              prop.userInfo = {dynamicDefaultValue: options[:default]}
            else
              prop.defaultValue = options[:default]
            end
          end
        end
      end

      def relation(name, options)
        options ||= {}
        (@properties ||= []) << NSRelationshipDescription.new.tap do |prop|
          prop.maxCount = 1
          prop.name = name
          prop.destinationEntity = const_get(options[:destination]).entity
          prop.inverseRelationship = options[:inverse] unless options[:inverse].nil?
        end
      end

      def activate!
        @entity = NSEntityDescription.new.tap do |ent|
          ent.name = class_name
          ent.managedObjectClassName = class_name
          ent.properties = @properties
        end
        Store.register(@entity)
      end

      def create(attrs = nil)
        Store.shared.add(class_name) do |data|
          props = data.entity.properties
          prop_names = props.map{|prop| prop.name}
          attrs.each do |key, value|
            raise MotionStore::NoPropertyError unless prop_names.include?(key.to_s)
            data.public_send(:"#{key}=", value)
          end unless attrs.nil?

          # set dynamic default value
          props.each do |prop|
            dynamic = prop.userInfo[:dynamicDefaultValue]
            if !dynamic.nil? && data.public_send(prop.name).nil?
              data.public_send(:"#{prop.name}=", dynamic.call)
            end
          end
        end
      end

      def all
        find
      end

      def delete_all
        all.each do |data|
          data.remove
        end
      end

      def find(condition = nil, sort = nil)
        request = build_request(condition, sort)
        Store.shared.fetch(class_name, withFetchRequest:request)
      end

      def count(condition = nil)
        request = build_request(condition, nil)
        Store.shared.count(class_name, withFetchRequest:request)
      end

      private
        def build_request(condition, sort)
          NSFetchRequest.new.tap do |req|
            req.entity = NSEntityDescription.entityForName(class_name, inManagedObjectContext:Store.shared.context)
            unless condition.nil?
              if condition.kind_of?(Array)
                predicate = NSPredicate.predicateWithFormat(condition[0], argumentArray:condition[1..-1])
              else
                predicate = NSPredicate.predicateWithFormat(condition)
              end
              req.predicate = predicate
            end
            unless sort.nil?
              if sort.kind_of?(Array)
                key = sort[0].to_s
                ascending = sort[1].to_sym == :desc ? false : true
              else
                key = sort.to_s
                ascending = true
              end
              req.sortDescriptors = [NSSortDescriptor.sortDescriptorWithKey(key, ascending:ascending)]
            end
          end
        end
    end
  end

end