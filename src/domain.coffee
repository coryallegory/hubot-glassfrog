# Description:
#   Glassfrog Domain
#   Multiple domains with identical descriptions are assumed to be the same domain applied through a hierarchy of circles and roles.
#

class Domain
  constructor: (@description) ->
    @domainIds = []
    @roleIds = []
    @roles = []
