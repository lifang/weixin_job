#encoding: utf-8
class PositionsController < ApplicationController   #招聘职位
  before_filter :has_sign?
  before_filter :get_company,only:[:show,:send_resume]
  skip_before_filter :has_sign? ,only:[:show,:send_resume]
  before_filter :get_title,:get_position_type,:get_positions,:get_work_addresses
  PerPage = 3

  def index
    time = Time.now.prev_month
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage*2,conditions:["(status =1 or status = 2) and created_at>=?",time])
    delivery_resume_records = DeliveryResumeRecord.where("position_id in (?)",@positions.map(&:id))
    @delivery_resume_records_group = delivery_resume_records.group_by{|drr| drr.position_id }
  end

  def history_index
    time = Time.now.prev_month
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage*2,conditions:["(status =1 or status = 2) and created_at <?",time])
    delivery_resume_records = DeliveryResumeRecord.where("position_id in (?)",@positions.map(&:id))
    @delivery_resume_records_group = delivery_resume_records.group_by{|drr| drr.position_id }
    render 'index'
  end
  def edit

  end
  
  def new
    @position = Position.new
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage,conditions:"status =1 or status = 2")
  end

  def edit
    @position = Position.find_by_id(params[:id])
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage,conditions:"status =1 or status = 2")
    render 'new'
  end

  def create
    id = params[:positions][:id]
    if id == ""
      types = params[:positions][:types]
      name = params[:positions][:name].strip
      description = params[:positions][:description]
      requirement = params[:positions][:requirement]
      address = params[:address_id]
      @position = Position.new
      @position.transaction do
        @position.position_type_id = types
        @position.name = name
        @position.description = description
        @position.requirement = requirement
        @position.status = Position::STATUS[:UNRELEASE]
        @position.company_id = @company.id
        if Position.find_by_name_and_company_id(name,@company.id).blank? && @position.save
          address.each do |ad|
            PositionAddressRelation.create(position_id:@position.id,
              work_address_id:ad,
              company_id:@company.id)
          end
          flash[:success] = "新建成功！"
          redirect_to company_positions_path(@company)
        else
          flash[:error] = "新建失败！职位已经存在！"
          redirect_to company_positions_path(@company)
        end
      end
    else
      update
    end
  end
  
  def update

    id = params[:positions][:id]
    name = params[:positions][:name].strip
    description = params[:positions][:description]
    types = params[:positions][:types]
    requirement = params[:positions][:requirement]
    address = params[:address_id]
    @position = Position.find_by_id(id)
    positions = Position.where(["name=? and company_id = ? and name !=?",name,@company.id,@position.name])
    if positions.length<1 
      if @position&& @position.update_attributes(name:name,
          requirement:requirement,
          description:description,
          position_type_id:types)
                                               
        PositionAddressRelation.where(["position_id = ?",@position.id]).destroy_all
        address.each do |ad|
          PositionAddressRelation.create(position_id:@position.id,
            work_address_id:ad,
            company_id:@company.id)
        end
        flash[:success] = "更新成功！"
        redirect_to company_positions_path(@company)
      else
        flash[:error] = "更新失败！职位不存在！"
        render 'new'
      end
    else
      flash[:error] = "更新失败！不能跟其他职位名称相同！"
      render 'new'
    end

  end

  def show
    @open_id = params[:secret_key]
    @position_types = @company.position_types || []
    @position = Position.find_by_id(params[:id])
    @client_resume = ClientResume.find_by_open_id_and_company_id(params[:secret_key],@company.id)
    if @position.blank?
      @title = "职位不存在，或者已经被删除"
      render 'public/404', :layout => false
    else
      render layout:false
    end
  end
  def send_resume
    if params[:from] != "singlemessage" && params[:from] != "timeline"
      delivery_resume_record = DeliveryResumeRecord.find_by_company_id_and_position_id_and_client_resume_id(@company.id,
        params[:position_id],
        params[:client_resume_id])
      if params[:client_resume_id].blank?
        @message = "投递失败</br>请先登记简历!"
      else
        if delivery_resume_record.nil?
          @delivery_resume_record = DeliveryResumeRecord.create(company_id:@company.id,
            position_id:params[:position_id],
            client_resume_id:params[:client_resume_id])
          @message = "投递成功！"
          send_noti_to_ios @company.id
        else
          @message = "您已经成功投递简历!"
        end
      end
      render 'success',layout:false
    else  
      @recomender_id = params[:open_id]
      @position_id =  params[:position_id]
      redirect_to "/client_resumes/create_friend_resume?company_id=#{@company.id}&recomender_id=#{@recomender_id}&position_id=#{@position_id}"
    end
  end
  
  def search_position
    p = params[:position]
    @positions = Position.where("company_id=#{@company.id} and name like ? and (status =1 or status = 2)","%#{p}%").paginate(page:params[:page],per_page: PerPage)||[]
    delivery_resume_records = DeliveryResumeRecord.where("position_id in (?)",@positions.map(&:id))
    @delivery_resume_records_group = delivery_resume_records.group_by{|drr| drr.position_id }
 
    render 'index'
  end

  def release   #发布
    common_update(Position::STATUS[:RELEASED],"发布")
  end
  def dis_release
    common_update(Position::STATUS[:UNRELEASE],"取消发布")
  end
  def destroy
    common_update(Position::STATUS[:DELETED],"删除")
  end
  def common_update(status,msg)
    @position = Position.find_by_id(params[:id])
    if @position && @position.update_attribute(:status,status)
      flash[:success] = "#{msg}成功！"
      if params[:format]=='0'
        redirect_to company_positions_path(@company)
      else
        redirect_to history_index_company_positions_path(@company)
      end
    else
      flash[:error] = "#{msg}失败，不存在职位，请刷新页面！"
      render 'index'
    end
  end

  def get_work_addresses
    @addr_and_position_relations = PositionAddressRelation.where(["company_id=?",@company.id])||[]
    @work_addresses = WorkAddress.select("work_addresses.id,work_addresses.address,c2.name province,c1.name city,work_addresses.company_id,work_addresses.created_at,work_addresses.updated_at").
      joins("left join cities c1 on c1.id = city_id").
      joins("left join cities c2 on c1.parent_id = c2.id").
      where(["work_addresses.company_id = ?",@company.id])||[]
  end

  def see_position
    @position = Position.where("(status =1 or status = 2) and id=?",params[:id])[0]
    if @position.blank?
      @status = 0
    else
      @status = 1
    end
  end

  def create_position
    @position = Position.new
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage,conditions:"status =1 or status = 2")
  end

  def edit_position
    
    @position = Position.find_by_id( params[:id])
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage,conditions:"status =1 or status = 2")
  end

  def get_positions
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage*2,conditions:"status =1 or status = 2")
  end

  def get_position_type
    @position_types = @company.position_types || []
  end

  def get_title
    @title = "招聘职位"
  end
  
  def get_company
    @company = Company.find_by_id(params[:company_id])
  end

end
