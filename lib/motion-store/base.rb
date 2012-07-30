module MotionStore
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
end