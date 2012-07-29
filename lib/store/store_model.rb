module StoreModel
  ATTR_TYPES = {
    undefined: NSUndefinedAttributeType,
    int16: NSInteger16AttributeType,
    int32: NSInteger32AttributeType,
    int64: NSInteger64AttributeType,
    decimal: NSDecimalAttributeType,
    double: NSDoubleAttributeType,
    float: NSFloatAttributeType,
    string: NSStringAttributeType,
    boolean: NSBooleanAttributeType,
    date: NSDateAttributeType,
    binary: NSBinaryDataAttributeType,
    transform: NSTransformableAttributeType
  }

  class NoPropertyError < StandardError
  end

  module ClassMethods
    def class_name
      self.to_s
    end

    def method_missing(method, *args)
      # TODO: define_methodがサポートされたらリファクタリング
      unless StoreModel::ATTR_TYPES[method].nil?
        field(args[0], method, *args[1..-1])
      else
        super
      end
    end

    def fields
      yield
      activate!
    end

    def field(name, type, *options)
      options = options[0]
      # TODO: オプションの実装
      #   optional, default, transient, index
      #   created_atなどの動的なデフォルト値も設定できるようにしたい
      # TODO: 関連の実装
      #   関連オブジェクトを定義できるようにしたい
      (@properties ||= []) << NSAttributeDescription.new.tap do |prop|
        prop.name = name
        prop.attributeType = StoreModel::ATTR_TYPES[type]
        prop.defaultValue = options[:default] if !options.nil? && !options.empty? && !options[:default].nil?
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
        props = data.entity.properties.map{|prop| prop.name}
        attrs.each do |key, value|
          raise StoreModel::NoPropertyError unless props.include?(key.to_s)
          data.public_send(:"#{key}=", value)
        end unless attrs.nil?
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
      request = NSFetchRequest.new.tap do |req|
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
      Store.shared.fetch(class_name, withFetchRequest:request)
    end
  end

  class Base < NSManagedObject
    extend StoreModel::ClassMethods

    def save
      Store.shared.save
    end

    def remove
      Store.shared.remove(self)
    end
  end

end