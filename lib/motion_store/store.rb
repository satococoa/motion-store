module MotionStore
  class Store
    attr_reader :context

    # CoreDataをコードのみで扱う
    @@entities = []

    class << self
      def self.shared
        @shared ||= Store.new
      end

      def register(entity)
        @@entities << entity
      end
    end

    def initialize
      model = NSManagedObjectModel.new
      model.entities = @@entities
      
      store = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
      store_url = NSURL.fileURLWithPath(
        File.join(NSHomeDirectory(), 'Documents', 'store.sqlite'))
      error_ptr = Pointer.new(:object)
      unless store.addPersistentStoreWithType(NSSQLiteStoreType,
        configuration:nil, URL:store_url, options:nil, error:error_ptr)
        raise "Can't add persistent SQLite store: #{error_ptr[0].description}"
      end

      context = NSManagedObjectContext.new
      context.persistentStoreCoordinator = store
      @context = context
    end

    def add(model_name)
      object = NSEntityDescription.insertNewObjectForEntityForName(
        model_name,
        inManagedObjectContext:@context
      )
      yield object
      save # TODO: Is this proper to be here?
      object
    end

    def remove(object)
      @context.deleteObject(object)
      save # TODO: Is this proper to be here?
    end

    def save
      error_ptr = Pointer.new(:object)
      unless @context.save(error_ptr)
        raise "Error when saving the model: #{error_ptr[0].description}"
      end
    end

    def reset
      @context.reset
    end

    def fetch(model_name, withFetchRequest:fetch_request)
      error_ptr = Pointer.new(:object)
      data = @context.executeFetchRequest(fetch_request, error:error_ptr)
      raise "Error when fetching data: #{error_ptr[0].description}" if data.nil?
      data
    end

    def count(model_name, withFetchRequest:fetch_request)
      error_ptr = Pointer.new(:object)
      data = @context.countFetchRequest(fetch_request, error:error_ptr)
      raise "Error when fetching data: #{error_ptr[0].description}" if data.nil?
      data
    end
  end
end