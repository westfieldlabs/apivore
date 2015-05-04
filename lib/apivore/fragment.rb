module Apivore
  # This is a workaround for json-schema's fragment validation which does not allow paths to contain forward slashes
  #  current json-schema attempts to split('/') on a string path to produce an array.
  class Fragment < Array
    def split(options = nil)
      self
    end
  end
end
