Things = app("Things")

class Issue < ActiveResource::Base
  self.site = "http://your-redmine-domain"
  self.user = "your-user-name"
  self.password = "your-password"
end

class Project < ActiveResource::Base
  self.site = "http://your-redmine-domain"
  self.user = "your-user-name"
  self.password = "your-password"
end
