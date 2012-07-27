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

  module ClassMethods
    def class_name
      self.to_s
    end

    def method_missing(method, *args)
      # TODO: define_methodがサポートされたらリファクタリング
      unless StoreModel::ATTR_TYPES[method].nil?
        field(args[0], method)
      else
        super
      end
    end

    def fields
      yield
      activate!
    end

    def field(name, type, *options)
      # TODO: オプションの実装
      # optional, default, transient, index
      (@properties ||= []) << NSAttributeDescription.new.tap do |prop|
        prop.name = name
        prop.attributeType = StoreModel::ATTR_TYPES[type]
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

    def create(attrs)
      Store.shared.add(class_name) do |data|
        attrs.each do |k, v|
          data.send(:"#{k}=", v)
        end
      end
    end

    def delete_all
      all.each do |data|
        data.remove
      end
    end

    def all
      # TODO: 重複だらけ。とりあえずコンソールでの確認用に実装。
      request = NSFetchRequest.new
      request.entity = NSEntityDescription.entityForName(self.to_s, inManagedObjectContext:Store.shared.context)
      Store.shared.fetch(self.to_s, withFetchRequest:request)
    end
  end

  class Base < NSManagedObject
    extend StoreModel::ClassMethods

    def remove
      Store.shared.remove(self)
    end
  end

end