require "serial/version"
require "serial/serializer"
require "serial/builder"
require "serial/hash_builder"
require "serial/array_builder"
require "serial/rails_helpers"

# Serial namespace. See {Serial::Serializer} for reference.
module Serial
  # All serial-specific errors inherit from this error.
  class Error < StandardError
  end

  # Raised when an already-defined key is defined again.
  class DuplicateKeyError < StandardError
  end
end
