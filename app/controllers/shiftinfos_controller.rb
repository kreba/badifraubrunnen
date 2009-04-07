class ShiftinfosController < ApplicationController

  before_filter do |c| c.restrict_access 'admin' end

  # GET /shiftinfos
  # GET /shiftinfos.xml
  def index
    @shiftinfos = Saison.shiftinfos_by_saison

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shiftinfos }
    end
  end

  # GET /shiftinfos/new
  # GET /shiftinfos/new.xml
  def new
    @shiftinfo = Shiftinfo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shiftinfo }
    end
  end

  # POST /shiftinfos
  # POST /shiftinfos.xml
  def create
    @shiftinfo = Shiftinfo.new(params[:shiftinfo])
    if current_person.is_admin_for_what.one?
      @shiftinfo.saison = current_person.is_admin_for_what.first
    else
      # TODO: add shiftinfo to user-defined saison
    end

    respond_to do |format|
      if @shiftinfo.save
        flash[:notice] = t'shiftinfos.create.success'
        format.html { redirect_to shiftinfos_path }
        format.xml  { render :xml => @shiftinfo, :status => :created, :location => @shiftinfo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shiftinfo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /shiftinfos/1
  # GET /shiftinfos/1.xml
  def show
    @shiftinfo = Shiftinfo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shiftinfo }
    end
  end

  # GET /shiftinfos/1/edit
  def edit
    @shiftinfo = Shiftinfo.find(params[:id])
  end

  # PUT /shiftinfos/1
  # PUT /shiftinfos/1.xml
  def update
    @shiftinfo = Shiftinfo.find(params[:id])

    respond_to do |format|
      if @shiftinfo.update_attributes(params[:shiftinfo])
        flash[:notice] = t'shiftinfos.update.success'
        format.html { redirect_to shiftinfos_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shiftinfo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shiftinfos/1
  # DELETE /shiftinfos/1.xml
  def destroy
    @shiftinfo = Shiftinfo.find(params[:id])
    @shiftinfo.destroy

    respond_to do |format|
      format.html { redirect_to shiftinfos_path }
      format.xml  { head :ok }
    end
  end
end
