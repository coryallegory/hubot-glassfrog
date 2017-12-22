# Description:
#   Glassfrog Role
#

class Role
  constructor: (@id, @isCircle, @name, @parentId, @domainIds) ->
    @parent = undefined
    @childIds = []
    @children = []
    @domains = []
    @memberIds = []
    @members = []
    @treeLevel = -1
