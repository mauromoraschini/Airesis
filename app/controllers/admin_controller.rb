#encoding: utf-8

#require 'airesis_metis'
require 'rake'

class AdminController < ApplicationController
  before_filter :admin_required#, :only => [:new, :create, :destroy]

  def index
   
  end
  
  def show        
   
  end
  
  #fa un test della gemma
  def test_gem
    
    AiresisMetis.hi
    
    
    respond_to do |format|
      format.html {
        flash[:notice] = 'OK'
        redirect_to admin_panel_path
      }
    end
  end
  
  #calcola il ranking degli utenti
  def calculate_ranking
    
    AdminHelper.calculate_ranking
    
    
    respond_to do |format|
      format.html {
        flash[:notice] = 'Ranking ricalcolato'
        redirect_to admin_panel_path
      }
    end
  end
  
  #cambia lo stato delle proposte
  def change_proposals_state
   AdminHelper.change_proposals_state
    
    respond_to do |format|
      format.html {        
        flash[:notice] = 'Stato proposte aggiornato'
        redirect_to admin_panel_path
      }
    end
  end
  
  def validate_groups
    AdminHelper.validate_groups
    
    
    respond_to do |format|
      format.html {
        flash[:notice] = 'Inviato elenco gruppi non validi'
        redirect_to admin_panel_path
      }
    end
  end
  
   def calculate_user_group_affinity
    AffinityHelper.calculate_user_group_affinity
       
    respond_to do |format|
      format.html {
        flash[:notice] = 'Affinità calcolate'
        redirect_to admin_panel_path
      }
    end
  end
  
  
  def delete_old_notifications
    deleted = AdminHelper.delete_old_notifications
        
    respond_to do |format|
      format.html {
        flash[:notice] = 'Notifiche eliminate: ' + deleted.to_s 
        redirect_to admin_panel_path
      }
    end
  end
  
  #invia una mail di prova tramite resque e redis
  def test_redis
    TestMailer.test.deliver
    #Resque.enqueue(TestSender)
    respond_to do |format|
      format.html {
        flash[:notice] = 'Test avviato' 
        redirect_to admin_panel_path
      }
    end
  end

  #invia una notifica di prova tramite resque e redis
  def test_notification
    ResqueMailer.notification(6200).deliver
    respond_to do |format|
      format.html {
        flash[:notice] = 'Test avviato'
        redirect_to admin_panel_path
      }
    end
  end

  #esegue un job di prova tramite resque_scheduler
  def test_scheduler
    Resque.enqueue_at(15.seconds.from_now, ProposalsWorker, :proposal_id => 1)
    respond_to do |format|
      format.html {
        flash[:notice] = 'Test avviato' 
        redirect_to admin_panel_path
      }
    end
    
    rescue Exception => e
	puts e.backtrace
  end
  
  
  def become
    sign_in User.find(params[:user_id]), :bypass => true
    redirect_to root_url # or user_root_url
  end

  def block
    User.find(params[:user_id]).update_attribute(:blocked,true)
    redirect_to admin_panel_path
  end

  def unblock
    User.find(params[:user_id]).update_attribute(:blocked,false)
    redirect_to admin_panel_path
  end
  
  def write_sitemap
    Rake::Task["sitemap:refresh"].invoke
    respond_to do |format|
      format.html {
        flash[:notice] = 'Sitemap aggiornata.'
        redirect_to admin_panel_path
      }
    end
  end


  def mailing_list

  end


  def send_newsletter
    ResqueMailer.publish(params['mail']['name'], :subject => params['mail']['subject'], :receiver => params['mail']['receiver'] ).deliver
    flash[:notice] = "Newsletter pubblicata correttamente"
    redirect_to :controller => 'admin', :action => 'mailing_list'
  end
  
end
