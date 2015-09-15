module Serial
  # Helpers for using Serial with Rails.
  module RailsHelpers
    # Find the serializer for `model` and serialize it in the context of self.
    #
    # @example serializing a single object
    #   render json: { person: serialize(Person.first) }
    #
    # @example serializing multiple objects
    #   render json: { people: serialize(Person.all) }
    #
    # @example serializing with explicit context
    #   render json: { people: serialize(presenter, Person.all) }
    #
    # @param context [#instance_exec]
    # @param model [#model_name, #each?]
    def serialize(context = self, model)
      klass = "#{model.model_name}Serializer".constantize

      if model.respond_to?(:each)
        klass.map(context, model)
      else
        klass.call(context, model)
      end
    end
  end
end
