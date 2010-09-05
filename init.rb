require 'rubygems'
require 'active_resource'
require 'appscript'
include Appscript
require 'api'

def pull_projects  
  @redmine_projects = Project.find(:all)
  @things_projects = Things.projects.get()
  @things_projects_collected = @things_projects.collect {|project| project.name.get()}
  @redmine_projects.each do |project|
    if @things_projects_collected.index(project.name).nil?
      Things.make(:new => :project, :with_properties => {:name => project.name})
    end
  end
end



def add_things_id_to_issue(id,tid)
  issue = Issue.find(id)
  issue.custom_field_values = {"1", tid}
  if issue.save
    puts issue.id
  else
    puts issue.errors.full_messages
  end
end

def pull_issues
  @redmine_issues = Issue.find(:all)
  @redmine_issues.each do |rs|
    begin
      tag = Things.tags['issue-id-'+rs.id].to_dos.get
      puts "Updating #{rs.subject}"      
      to_dos = Things.tags['issue-id-'+rs.id].get.to_dos.get
      to_do = to_dos[0]
      to_do.name.set(rs.subject)
      unless rs.description.nil?
        notes = rs.description+" http://issues.theablefew.com/#{rs.id}"
        to_do.notes.set(notes)
        
      end
      to_do.project.set(Things.projects[rs.project.name])
      to_do.tag_names.set("issue-id-"+rs.id)
    rescue
      puts "Doesn't exist"
      puts "Creating #{rs.subject}"

      to_do = Things.make(:new => :to_do, :with_properties =>{
        :name => rs.subject
        }
      )
      unless rs.description.nil?
        notes = rs.description+" http://issues.theablefew.com/#{rs.id}"
        to_do.notes.set(notes)
      end
      to_do.tag_names.set("issue-id-"+rs.id)
      to_do.project.set(Things.projects[rs.project.name])
      add_things_id_to_issue(rs.id, to_do.object_id)
    end
    puts rs.status.name
    puts rs.id
    puts "=-------------------------"
    if rs.status.name == "closed"
      puts "#{rs.id} should be closed"
      to_do.status.set("completed")
    end
  end
end




def push_issues
  puts "Pushing Issues"
  to_dos = Things.to_dos.get
  to_dos.each do |to_do|
    path = to_do.inspect.split('.')
    if path[2] == "projects"
    else
      tags = to_do.tag_names.get
      puts tags.gsub("issue-id-","")
      issue = Issue.find(tags.gsub("issue-id-",""))
      status = to_do.status.get
      status = status.to_s
      if status == "completed"
        puts "should make it complete"
        if issue.status.name != "Closed"
          issue.status_id = 5
          if issue.save
            puts issue.id
          else
            puts issue.errors.full_messages
          end
        else
          puts "It's already closed. Nothing left to do."
        end
      end
    end
  end
end

pull_projects
pull_issues
push_issues