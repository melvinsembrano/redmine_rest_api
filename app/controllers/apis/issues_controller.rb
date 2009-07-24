class Apis::IssuesController < ApplicationController
  skip_before_filter :check_if_login_required
  before_filter :authenticate
  before_filter :setup_controller

  def index
    last_update = Time.parse(params[:lu]) if params[:lu]
    if last_update
      @issues = @project.issues.find(:all, :conditions => ["updated_on > ?",last_update.utc? ? last_update.localtime : last_update])
    else
      @issues = @project.issues
    end

    respond_to do |format|
      format.html
      
      format.xml { render :xml => @issues.to_xml(:include => {:attachments => {:only => [:id, :description, :filename], :methods => [:download_url]}, :author => {:only => [:id, :lastname, :firstname]},
          :assigned_to => {:only => [:id, :lastname, :firstname]}},
          :methods => [:spent_hours]) }

      format.json { render :json => @issues.to_json(:include => {:attachments => {:only => [:id, :description, :filename], :methods => [:download_url]}, :author => {:only => [:id, :lastname, :firstname]},
          :assigned_to => {:only => [:id, :lastname, :firstname]}},
          :methods => [:spent_hours]) }
    end
  end

  #create new ticket
  def create
    @issue = Issue.new(params[:issue])
    respond_to do |format|
      if @issue.save
        format.html
        format.xml { render :xml => @issue, :status => :ok }
        format.json { render :json => @issue, :status => :ok }
      else
        format.html
        format.xml  { render :xml => @issue.errors, :status => :unprocessable_entity }
        format.json  { render :json => @issue.errors, :status => :unprocessable_entity }
      end
    end

  end

  #update existing ticket
  def update
    @issue = Issue.find(params[:id])
    respond_to do |format|
      if @issue.update_attributes(params[:issue])
        format.html
        format.xml { render :xml => @issue, :status => :ok }
        format.json { render :json => @issue, :status => :ok }
      else
        format.html
        format.xml  { render :xml => @issue.errors, :status => :unprocessable_entity }
        format.json  { render :json => @issue.errors, :status => :unprocessable_entity }
      end
    end
  end

  def details
    @issue = @project.issues.find(params[:id])
    @attachments = @issue.attachments.collect {|a| {:description => a.description, :url => a.download_url}}

    if params[:last_comment]
      #@comments = @issue.journals.find(:all, :conditions => ["id > ?", params[:last_comment]])
    else
      #@comments = @issue.journals
    end
    
    respond_to do |format|
      format.html
      format.xml { render :xml => {'attachments' => @attachments } }
      format.json { render :json =>  {'attachments' => @attachments } }
    end
  end

  def comments
    @issue = @project.issues.find(params[:id])
    if params[:last_comment]
      @comments = @issue.journals.find(:all, :conditions => ["id > ? and notes <> ?", params[:last_comment], ""])
    else
      @comments = @issue.journals.find(:all, :conditions => ["notes <> ?", ""])
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @comments.to_xml(:include => {:user => {:only => [:id, :lastname, :firstname]}}   ) }
      format.json { render :json => @comments.to_json(:include => {:user => {:only => [:id, :lastname, :firstname]}}) }
    end
  end

  def add_comment
    @issue = @project.issues.find(params[:id])    
    journal = Journal.new(:journalized_id => @issue.id, :journalized_type => "Issue", :user_id => @user.id, :notes => params[:remarks])
    
    respond_to do |format|
      if journal.save
        format.html
        format.xml { render :xml => journal.to_xml(:include => {:user => {:only => [:id, :lastname, :firstname]}} ), :status => :ok}
        format.json { render :json => journal.to_json(:include => {:user => {:only => [:id, :lastname, :firstname]}} ), :status => :ok }
      else
        format.html
        format.xml { render :xml => journal.errors , :status => :unprocessable_entity}
        format.json { render :json => journal.errors , :status => :unprocessable_entity }
      end
    end
  end

  protected

  def setup_controller
    @project = Project.find(params[:project_id]) if params[:project_id]
  end
end
