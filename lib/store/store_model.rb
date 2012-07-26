# model に include して使う
module StoreModel
  def self.included(model)
    Store.register(model.entity)
    model.extend ClassMethods
  end

  def remove
    Store.shared.remove(self)
  end

  module ClassMethods
    def create(attrs)
      Store.shared.add(self.to_s) do |data|
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

end