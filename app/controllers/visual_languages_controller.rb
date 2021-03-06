class VisualLanguagesController < ApplicationController

	def getLanguages
		#VisualJob.select(:language).group(:language).order("count_language desc").count()
		languageJobs = VisualJob.select("lower(language)").group("lower(language)").order("count_lower_language desc").count()
	
		languages = Array.new

		#regexp for checking if language is valid
		#remove all languages that begin with ---
		#maybe you could also ask for languages begin with a letter ^[a-zA-Z]
		reg = Regexp.new("^[^- ]")

		languageJobs.each do |job|
			if reg.match(job[0])
				languages << job
			end
		end

		return languages
	end


	def getLanguagesForSelect
		languages = VisualJob.select("lower(language) AS language").uniq.order(:language)
	end


	def compare 
		languageJobs = getLanguagesForSelect

		@languages = Array.new

		#regexp for checking if language is valid
		#remove all languages that begin with ---
		#maybe you could also ask for languages begin with a letter ^[a-zA-Z]
		reg = Regexp.new("^[^- ]")

		languageJobs.each do |job|

			if reg.match(job.language)
				@languages << [job.language, job.language]
			end
		end

		respond_to do |format|
			format.html # compare.html.erb
			format.json { render json: @languages }
		end
	end

	def listLanguages
		
		@languages = getLanguages

		respond_to do |format|
			format.html { render :layout => false} # listLanguages.html.erb
			format.json { render json: @languages }
		end
	end

	def listLanguagesOverview

		@languages = getLanguages

		respond_to do |format|
			format.html # listLanguagesOverview.html.erb
			format.json { render json: @languages }
		end
	end


	def listJobsForLanguages
		@languages = Array.new 

		

		reg = Regexp.new('^language[1-5]$')

		request.params.each do |param, lang|
			if reg.match(param)
				@languages << lang
			end
		end

		ui = request.params[:ui].to_i

		@languageStats = Array.new

		@languages.each do |lang|
			stat = Hash.new
			stat['language'] = lang
			#stat['positiv'] = VisualJob.where("language = '#{lang}' AND result=1").count

			#besser aufgrund von SQL injection!!
			stat['positiv'] = VisualJob.where(language: lang).where(result: 0).order(:finished_at).count(:id)

			stat['negativ'] = VisualJob.where(language: lang).where(result: 1).order(:finished_at).count(:id)
			stat['total'] = VisualJob.where(language: lang).order(:finished_at).count(:id)
			if stat['total'] > 0 
				stat['percentage'] = (stat['positiv']*100.0/stat['total']).round(2)
			else
				stat['percentage'] = (0).round(2)
			end
			@languageStats << stat
		end

		@stats = Hash.new
		@stats['languageStats']=@languageStats
		@stats['draw']=VisualBuild.getJobsByAmount(@languages,-1).to_json
		
		if(ui > 0)
			respond_to do |format|
				format.html { render :layout => false }# listJobsForLanguages.html.erb
				format.json { render json: @stats }
			end
		else
			respond_to do |format|
				format.html { render :layout => 'frame' }
				format.json { render json: @stats }
			end
		end

	end

end
