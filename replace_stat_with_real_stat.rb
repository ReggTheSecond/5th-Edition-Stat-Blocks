=begin
  When this script is complete the workflow will be:

  - Run the script, pass a html stat block
  - The Script will then:
    - Determine if there is a hidden document in the directory that shares a file name
    - If there is a hidden version of the pre prased document the script will ask if you want to use the attributes in the new file to update the parseable options in the old versions
    -
=end

def get_attribute(line)
  thing = line.strip().split("=\"").last().split(/\"$/).first()
  return thing.to_i
end

def get_challenge_rate(line)
  thing = line.strip().split("<p>").last().split("</p>").first().split("(").first()
  return thing.to_i
end

def get_attribute_bonus(attribute_score)
  if attribute_score > 10
    attribute_score = (attribute_score - 10) / 2
  elsif attribute_score == 10
    attribute_score = 0
  else
    attribute_score = attribute_score / 2
    attribute_score = attribute_score - (attribute_score + 1)
  end
  return attribute_score
end

def get_proficiency_bonus(challenge_rating)
  if challenge_rating < 4
    proficiency_bonus = 2
  elsif challenge_rating >= 5 && challenge_rating < 9
    proficiency_bonus = 3
  elsif challenge_rating >= 9 && challenge_rating < 13
    proficiency_bonus = 4
  elsif challenge_rating >= 13 && challenge_rating < 17
    proficiency_bonus = 5
  elsif challenge_rating >= 17 && challenge_rating < 21
    proficiency_bonus = 6
  elsif challenge_rating >= 21 && challenge_rating < 25
    proficiency_bonus = 7
  elsif challenge_rating >= 25 && challenge_rating < 29
    proficiency_bonus = 8
  elsif challenge_rating >= 29
    proficiency_bonus = 9
  end
  return proficiency_bonus
end

def get_attribute_bonus_plus_proficiency_bonus(attribute_bonus, proficiency_bonus)
  return attribute_bonus + proficiency_bonus
end

def add_bonuses_to_html_stat_block(line, strength, dexterity, constitution, intelligence, wisdom, charisma, challenge_rating)
  if line.match /\(#strBonus\+#proficiencyBonus\)/
    line = line.gsub("(#strBonus+#proficiencyBonus)", "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(strength), get_proficiency_bonus(challenge_rating))}")
  elsif  line.match /\(#dexBonus\+#proficiencyBonus\)/
    line = line.gsub("(#strBonus+#proficiencyBonus)", "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(dexterity), get_proficiency_bonus(challenge_rating))}")
  elsif  line.match /\(#conBonus\+#proficiencyBonus\)/
    line = line.gsub("(#strBonus+#proficiencyBonus)", "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(constitution), get_proficiency_bonus(challenge_rating))}")
  elsif  line.match /\(#intBonus\+#proficiencyBonus\)/
    line = line.gsub("(#strBonus+#proficiencyBonus)", "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(intelligence), get_proficiency_bonus(challenge_rating))}")
  elsif  line.match /\(#wisBonus\+#proficiencyBonus\)/
    line = line.gsub("(#strBonus+#proficiencyBonus)", "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(wisdom), get_proficiency_bonus(challenge_rating))}")
  elsif  line.match /\(#chaBonus\+#proficiencyBonus\)/
    line = line.gsub("(#strBonus+#proficiencyBonus)", "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(charisma), get_proficiency_bonus(challenge_rating))}")
  elsif line.match /#strBonus/
    line = line.gsub("#strBonus", "#{get_attribute_bonus(strength)}")
  elsif line.match /#dexBonus/
    line =  line.gsub("#dexBonus", "#{get_attribute_bonus(dexterity)}")
  elsif line.match /#conBonus/
    line =  line.gsub("#conBonus", "#{get_attribute_bonus(constitution)}")
  elsif line.match /#intBonus/
    line =  line.gsub("#intBonus", "#{get_attribute_bonus(intelligence)}")
  elsif line.match /#wisBonus/
    line =  line.gsub("#wisBonus", "#{get_attribute_bonus(wisdom)}")
  elsif line.match /#chaBonus/
    line =  line.gsub("#chaBonus", "#{get_attribute_bonus(charisma)}")
  end
  return line
end

directory_file_name = ARGV[0]

file = File.open(directory_file_name, "a+")
strength = ""
dexterity = ""
constitution = ""
intelligence = ""
wisdom = ""
charisma = ""
challenge_rating = ""
document = ""
old_document = ""
file.each_line do |line|
  old_document << line

  if line.match /data-str=/
    strength = get_attribute(line)
  elsif line.match /data-dex=".+"/
    dexterity = get_attribute(line)
  elsif line.match /data-con=".+"/
    constitution = get_attribute(line)
  elsif line.match /data-int=".+"/
    intelligence = get_attribute(line)
  elsif line.match /data-wis=".+"/
    wisdom = get_attribute(line)
  elsif line.match /data-cha=".+"/
    charisma = get_attribute(line)
  elsif line.match /<h4>Challenge<\/h4><p>.+<\/p>/
    challenge_rating = get_challenge_rate(line)
  end
  if challenge_rating != ""
    line = add_bonuses_to_html_stat_block(line, strength, dexterity, constitution, intelligence, wisdom, charisma, challenge_rating)
  end
  document << line
end
file.truncate(0)

file << document
file.close()

file_name = directory_file_name.split("/").last()
file_directory = directory_file_name.split(file_name).first
old_file = File.new("#{file_directory}.#{file_name}", "w")
old_file << old_document
old_file.close()
