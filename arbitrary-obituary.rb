require 'active_support'
require 'active_support/core_ext'
require 'csv'

class Hash
	def weighted_sample
		n = rand * self.values.reduce(:+)
		self.detect{ |k, v| (n -= v) < 0 }.first
	end
end

class Obituary
	def output
		"#{announcementTemplate} #{deathTemplate} #{birthTemplate}"	# TODO: Expand this
	end
	
	def reoutput
		instance_variables.each{ |i| remove_instance_variable(i) }
		output
	end
	
	###########
	# Content #
	###########
	
	def age
		@age ||= deathDate.year - birthDate.year - (deathDate.month < birthDate.month ? 1 : 0)
	end
	
	def announcementTemplate
		@announcementTemplate ||= [
			"#{firstName} #{middleInitial ? middleInitial + " " : ""}#{lastName} (#{birthDate.year} - #{deathDate.year})"
		].sample
	end
	
	def birthTemplate
		@birthTemplate ||= [
			"#{pronounSubject.capitalize} was born #{birthDate.strftime("%B %-d, %Y")} in #{birthLocation} to #{fatherFirstName} #{fatherLastName} and #{motherFirstName} #{motherLastName}. #{pronounSubject.capitalize} attended #{highSchool}."
		].sample
	end
	
	def birthDate
		@birthDate ||= Time.new - Array(25..110).sample.years	# TODO: Change this to a weighted hash, based on available mortality rates by age
	end
	
	def birthLocation
		@birthLocation ||= location!
	end
	
	def deathTemplate
		@deathTemplate ||= [
			"#{deathEuphemism} #{preposition} #{deathCause} at the age of #{age}.",
			"#{deathEuphemism} #{deathLocation} at the age of #{age}."
		].sample
	end
	
	def deathCause
		@deathCause ||= [
			"cancer",
			"old age",
			"#{pronounPossessive} wounds",
			"a broken heart"
		].sample
	end
	
	def deathDate
		@deathDate ||= Time.new - Array(1..35).sample.days
	end
	
	def deathEuphemism
		@deathEuphemism ||= [
			"died",
			"passed",
			"passed away",
			"lost #{pronounPossessive} battle",
			"lost #{pronounPossessive} fight"
		].sample
	end
	
	def deathLocation
		@deathLocation ||= [
			"in #{pronounPossessive} home",
			"in #{location!}",
			"at #{location!} Hospital"
		].sample
	end
	
	def fatherFirstName
		# TODO: Make sure my list of names actually covers the oldest possible year.
		# TODO: Dynamically determine father's birth date based on parental age data.
		@fatherFirstName ||= firstName!(birthDate: birthDate - Array(20..40).sample.years, gender: "male")
	end
	
	def fatherLastName
		@fatherLastName ||= lastName!
	end
	
	def firstName
		@firstName ||= firstName!
	end
	
	def firstName!(birthDate: self.birthDate, gender: self.gender)
		CSV::read("names/first/yob#{birthDate.year}.txt")
		.map{ |row| {:name => row[0], :gender => (row[1] == 'F' ? 'female' : 'male'), :count => row[2].to_i} }
		.select{ |row| row[:gender].to_s == gender.to_s }
		.map{ |row| [row[:name], row[:count]] }
		.to_h
		.weighted_sample
	end
	
	def gender
		@gender ||= {
			"male" => 138053563,
			"female" => 143368343
		}.weighted_sample
	end
	
	def highSchool
		@highSchool ||= "#{location!} High School"
	end
	
	def lastName
		@lastName ||= lastName!
	end
	
	def lastName!
		CSV::read("names/last.txt")
		.map{ |row| [row[0].capitalize, row[1].to_i] }
		.to_h
		.weighted_sample
	end
	
	def location!
		firstPart = %w[
			Lake
			River
			Green
			Clover
			Hill
			Maple
			Oak
			Ash
			Birch
			Pine
			Larch
			Elm
		].sample
		lastPart = %w[
			view
			creek
			bridge
			land
			ville
			ton
			shire
			town
			vale
			wood
			ford
			brook
			dale
		].sample
		
		return "#{firstPart}#{lastPart}"	# TODO: Replace this with an actual placename list
	end
	
	def middleInitial
		@middleInitial ||= CSV::read("names/first/yob#{birthDate.year}.txt")
		.map{ |row| {:name => row[0], :gender => (row[1] == 'F' ? 'female' : 'male'), :count => row[2].to_i} }
		.select{ |row| row[:gender].to_s == gender.to_s }
		.reduce(Hash.new(0)){ |m, row| m[row[:name][0]] += row[:count]; m }
		.weighted_sample
	end
	
	def motherFirstName
		@motherFirstName ||= firstName!(birthDate: birthDate - Array(20..40).sample.years, gender: "female")
	end
	
	def motherLastName
		# TODO: Determine the actual likelihood that the mother does not have the same last name as the father.
		@motherLastName ||= (Random.rand > 0.2 ? fatherLastName : lastName!)
	end
	
	def preposition
		@preposition ||= %w[
			from
			of
		].sample
	end
	
	def pronounObject
		case gender
		when "male" then return "him"
		when "female" then return "her"
		when "neuter" then return "them"
		end
	end
	
	def pronounPossessive
		case gender
		when "male" then return "his"
		when "female" then return "her"
		when "neuter" then return "their"
		end
	end
	
	def pronounSubject
		case gender
		when "male" then return "he"
		when "female" then return "she"
		when "neuter" then return "they"
		end
	end
end

##
# Name/Announcement:
# - Full name of the deceased, including nickname, if any	(TODO: Nicknames)
# - Age at death
# - Residence (for example, the name of the city) at death
# - Day and date of death (remember to include the year)
# - Place of death
# - Cause of death
#
# life:
# - Date of birth
# - Place of birth
# - Names of parents
# - Childhood: siblings, stories, schools, friends
# - Marriage(s): date of, place, name of spouse
# - Education: school, college, university and other
# - Designations, awards, and other recognition
# - Employment: jobs, activities, stories, colleagues, satisfactions, promotions, union activities, frustrations
# - Military service
# - Places of residence
# - Hobbies, sports, interests, activities, and other enjoyment
# - Charitable, religious, fraternal, political, and other affiliations; positions held
# - Achievements
# - Disappointments
# - Unusual attributes, humor, other stories
#
# Family:
# - Survived by (and place of residence):
# - Spouse
# - Children (in order of date of birth, and their spouses)
# - Grandchildren
# - Great-grandchildren
# - Great-great-grandchildren
# - Parents
# - Grandparents
# - Siblings (in order of date of birth)
# - Others, such as nephews, nieces, cousins, in-laws
# - Friends
# - Pets (if appropriate)
# - Predeceased by (and date of death):
# - Spouse
# - Children (in order of date of birth)
# - Grandchildren
# - Siblings (in order of date of birth)
# - Others, such as nephews, nieces, cousins, in-laws
# - Pets (if appropriate)
#
# Service:
# - Day, date, time, place
# - Name of officiant, pallbearers, honorary pallbearers, other information
# - Visitation information if applicable: day, date, time, place
# - Reception information if applicable: day, date, time, place
# - Other memorial, vigil, or graveside services if applicable: day, date, time, place
# - Place of interment
# - Name of funeral home in charge of arrangements
# - Where to call for more information (even if no service planned)
#
# End:
# - Memorial funds established
# - Memorial donation suggestions, including addresses
# - Thank you to people, groups, or institutions
# - Quotation or poem
# - Three words that sum up the life