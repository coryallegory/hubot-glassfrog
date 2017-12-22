# Description:
#   Glassfrog Member
#

class Member
  constructor: (@id, @name, @email) ->
    @rolesIds = []
    @roles = []
