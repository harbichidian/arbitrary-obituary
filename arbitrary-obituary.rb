class Hash
	def weighted_sample
		n = rand * self.values.reduce(:+)
		self.detect{ |k, v| (n -= v) < 0 }.first
	end
end

class Obituary
	def output
		"#{announcement} #{death} #{birth}"	# TODO: Expand this
	end
	
	def reoutput
		instance_variables.each{ |i| remove_instance_variable(i) }
		output
	end
	
	def method_missing(m)
		instVarName = "@#{m}"
		classVarName = "@@#{m}s"
		
		if instance_variable_defined? instVarName
			instance_variable_get instVarName
		elsif self.class.class_variable_defined? classVarName	# TODO: Need to use class methods and define a class method_missing. When the class method_missing returns, save that in the instance variable before returning
			classVar = self.class.class_variable_get classVarName
			if classVar.respond_to?(:weighted_sample)
				instance_variable_set(instVarName, classVar.weighted_sample)
			elsif classVar.respond_to?(:sample)
				instance_variable_set(instVarName, classVar.sample)
			end
		end
	end
	
	@@ages = 25..120	# TODO: Change this to a weighted hash, based on available mortality rates by age
	
	@@announcements = [
		"#{firstName} #{middleInitial ? middleInitial + " " : ""}#{lastName} (#{birthDate} - #{deathDate})"
	]
	
	@@births = [
		"#{pronoun.capitalize} was born #{birthDate} in #{birthLocation} to #{fatherFirstName} #{fatherLastName} and #{motherFirstName} #{motherLastName}. #{pronoun} attended #{highSchool}"
	]
	
	@@birthDates = []
	
	@@deaths = [
		"#{deathEuphemism} #{preposition} #{deathCause} at the age of #{age}",
		"#{deathEuphemism} #{deathLocation} at the age of #{age}"
	]
	
	@@deathCauses = []
	
	@@deathDates = []
	
	@@deathEuphemisms = []
	
	@@firstNames = []
	
	@@lastNames = []
	
	@@middleInitials = []
	
	@@prepositions = []
	
	@@pronouns
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