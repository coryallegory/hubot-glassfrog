# Description:
#   Datastore for Glassfrog entities
#

# API key for Glassfrog organization
APIKEY  = process.env.HUBOT_GLASSFROG_APIKEY

# refresh requests won't be performed more than once over this interval in seconds
REFRESH_RATE = process.env.HUBOT_GLASSFROG_REFRESHRATE || 60

class GlassfrogData
  constructor: ->
    @gccId = undefined
    @gccRole = undefined
    @rawJsonData = undefined
    @roles = []
    @rolesById = {}
    @domains = []
    @domainsById = {}
    @domainsByDescription = {}
    @members = []
    @membersById = {}
    @lastRefreshDate = undefined

  secondsSinceLastRefresh: () =>
    if @lastRefreshDate == undefined
      return Number.MAX_SAFE_INTEGER
    return ((new Date()) - @lastRefreshDate) / 1000

  #callback passes err message or null
  refresh: (robot, callback) =>
    if @secondsSinceLastRefresh() < REFRESH_RATE
      console.log("Glassfrog data checks cannot be made more than once every #{REFRESH_RATE} seconds")
      callback(undefined)
      return

    robot.http("https://api.glassfrog.com/api/v3/roles")
      .header('Content-Type', 'application/json')
      .header('X-Auth-Token', APIKEY)
      .get() (err, response, body) =>
        if err
          callback(err)
          return
        @rawJsonData = JSON.parse body

        #build roles
        for r in @rawJsonData.roles
          role = new Role(r.links.supporting_circle || r.id, r.links.supporting_circle == null, r.name, r.links.circle, r.links.domains)
          @roles.push role
          @rolesById[role.id] = role
          if role.circleId == null
            @gccId = role.id
            @gccRole = role
        #build role tree links
        for r in @roles
          if r.parentId
            r.parent = @rolesById[r.parentId]
            r.parent.children.push r
        for r in @roles
          r.treeLevel = 0
          role = r
          while role.id != @gccId
            role = role.parent
            r.treeLevel = r.treeLevel+1
        #build domains
        for d in @rawJsonData.linked.domains
          domain = @domainsByDescription[d.description]
          if !domain
            domain = new Domain(d.description)
            @domains.push domain
            @domainsByDescription[d.description] = domain
          domain.domainIds.push d.id
          @domainsById[d.id] = domain
        #build members and link with roles
        for m in @rawJsonData.linked.people
          member = new Member(m.id, m.name, m.email)
          for roleId in m.links.circles
            role = rolesById[roleId]
            role.memberIds.push member.id
            role.members.push member
            if !role.isCircle
              member.roleIds.push role.id
              member.roles.push role              
          members.push member
          membersById[member.id] = member
        #assign roles and domains links
        for role in @roles
          for domainId in role.domainIds
            domain = @domainsById[domainId]
            if !domain
              err = "Domain with id #{domainId} not found for role with id #{role.id}"
              callback(err)
              return
            role.domains.push domain
            domain.roleIds.push role.id
            domain.roles.push role
        
        @lastRefreshDate = new Date()
        callback(undefined)
