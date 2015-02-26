class HomeController < ApplicationController


  def lan
    if current_user
      client = Restforce.new :oauth_token => current_user.oauth_token,
                             :refresh_token => current_user.refresh_token,
                             :instance_url => current_user.instance_url,
                             :client_id => Rails.application.config.salesforce_app_id,
                             :client_secret => Rails.application.config.salesforce_app_secret

      #user info
      @user_info = client.query("select Id, Name from User")
      @user_info_hash = Hash.new
      @user_info.each { |info| @user_info_hash.merge!("#{info['Id']}" => "#{info['Name']}") }
      @user_info_hash

      #account info
      @account_info = client.query("select Id, Name from Account")
      @acc_info_hash = Hash.new
      @account_info.each { |info| @acc_info_hash.merge!("#{info['Id']}" => "#{info['Name']}") }
      @acc_info_hash

      #getting Opportunity info
      @opp_info = client.query("select ownerid, accountid, Name from Opportunity")
      @opp_info_hash = Hash.new
      @opp_info.each { |info|
        if @opp_info_hash.has_key?("#{info['AccountId']}")
          @opp_info_hash["#{info['AccountId']}"].push("#{@user_info_hash["#{info['OwnerId']}"]}")
        else
          @opp_info_hash["#{info['AccountId']}"] = Array.new
          @opp_info_hash["#{info['AccountId']}"].push("#{@user_info_hash["#{info['OwnerId']}"]}")
        end
      }
      @opp_info_hash

      #json generation
      @json_output = Array.new
      a = Array.new
      @opp_info_hash.select { |key, value|
        @json_output << ({'account' => "#{@acc_info_hash[key]}", 'users' => value.uniq})
      }

      @save_object = Home.new(:object => @json_output.to_json)
      @save_object.save
      #@json_output = @json_output.to_json
    end
  end

  def search
    search_text = params['text'].downcase
    @match_json = Array.new
    search_result = Home.all
    search_result.each { |jsn|
      if jsn.object.downcase.include? search_text
        @match_json << jsn
      end
    }
  end


end




