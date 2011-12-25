require 'sinatra'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/data.db")
DataMapper::Model.raise_on_save_failure = true

set :public_folder, File.dirname(__FILE__) + '/views'

class Visit
    include DataMapper::Resource
    property :id, Serial
    property :ip, String
    property :count, Integer
    
    def self.doVisit ip
	visit = Visit.first(:ip => ip)
	
	if visit
	    visit.update :count => (visit.count + 1)
	else
	    Visit.create :ip => ip, :count => 1
	end
    end
end

class Post
    include DataMapper::Resource
    property :id, Serial
    property :pid, Integer
    property :pname, String
    property :ip, String
    property :name, String, :required => true
    property :content, Text, :required => true
    property :created_at, DateTime
end

Post.auto_migrate! unless Post.storage_exists?
Visit.auto_migrate! unless Visit.storage_exists?
DataMapper.auto_upgrade!

get '/' do
    ip = request.ip
    Visit.doVisit ip
    erb :index
end

get '/msg' do
    ip = request.ip
    Visit.doVisit ip

    @posts = Post.all(:order => [:created_at.desc])
    erb :msg
end

post '/new' do
    p = Post.new
	p.pid = params[:pid] if params[:pid] != ""
	p.pname = params[:pname] if params[:pname] != ""
	p.name = params[:name]
	p.ip = request.ip
	p.content = params[:content]
	p.created_at = Time.now
    p.save
    redirect '/msg'
end

get '/admin/:name/:pass' do
    name = params[:name]
    pass = params[:pass]
    if name == "xxxxx" && pass == "xxxxx"
	@posts = Post.all(:order => [:created_at.desc])
	@visits = Visit.all(:order => [:count.desc])
	erb :admin
    else
	redirect '/'
    end
end

post '/deletePost' do
    post = Post.get params[:id]
    post.destroy if post 
    redirect '/admin/admin/admin'
end

get '/draw' do
    ip = request.ip
    Visit.doVisit ip
    
    erb :draw
end
