# `Current` class facilitates easy access to global, per-request attributes
# without passing them deeply around everywhere.
# `Current` should only be used for a few, top-level globals.
#
# https://edgeapi.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html
#
class Current < ActiveSupport::CurrentAttributes
  attribute :request_id
end
