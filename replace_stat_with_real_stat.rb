class StatBlockedParser
  attr_accessor :strength
  attr_accessor :dexterity
  attr_accessor :constitution
  attr_accessor :intelligence
  attr_accessor :wisdom
  attr_accessor :charisma
  attr_accessor :challenge_rating

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
    if challenge_rating <= 4
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

  def get_passive_perception(wisdom, proficiencyBonus)
    return 10 + wisdom + proficiencyBonus
  end

  def spell_save_attribute(spell_attribute)
    if spell_attribute == "str"
      return @strength
    elsif spell_attribute == "dex"
      return @dexterity
    elsif spell_attribute == "con"
      return @constitution
    elsif spell_attribute == "int"
      return @intelligence
    elsif spell_attribute == "wis"
      return @wisdom
    elsif spell_attribute == "cha"
      return @charisma
    end
  end

  def get_spell_save(spell_attribute, proficiency_bonus)
    return 8 + get_attribute_bonus(spell_attribute) + proficiency_bonus
  end

  def get_spell_attack(spell_attribute, proficiency_bonus)
    return get_attribute_bonus(spell_attribute) + proficiency_bonus
  end

  def get_spell_save_attribute(document)
    document.each_line do |line|
      if line.match(/((\d<!-- \(#spellSaveDC:...\) -->|\d\d<!-- \(#spellSaveDC:...\) -->)|<!-- \(#spellSaveDC:...\) -->)/)
        return line.split("spellSaveDC:").last().split(") -->").first()
      end
    end
  end

  def get_spell_attack_attribute(document)
    document.each_line do |line|
      if line.match(/((\d<!-- \(#spellAttackBonus:...\) -->|\d\d<!-- \(#spellAttackBonus:...\) -->)|<!-- \(#spellAttackBonus:...\) -->)/)
        return line.split("spellAttackBonus:").last().split(") -->").first()
      end
    end
  end

  def start_parse(document)
    return parse_strength(document)
  end

  def parse_strength(document)
    return parse_dexterity(document.gsub(/((\d\d<!-- \(#strBonus\) -->|\d<!-- \(#strBonus\) -->)|<!-- \(#strBonus\) -->)/,
    "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(@strength), 0)}<!-- (#strBonus) -->"))
  end

  def parse_dexterity(document)
    return parse_constitution(document.gsub(/((\d\d<!-- \(#dexBonus\) -->|\d<!-- \(#dexBonus\) -->)|<!-- \(#dexBonus\) -->)/,
    "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(@dexterity), 0)}<!-- (#dexBonus) -->"))
  end

  def parse_constitution(document)
    return parse_intelligence(document.gsub(/((\d\d<!-- \(#conBonus\) -->|\d<!-- \(#conBonus\) -->)|<!-- \(#conBonus\) -->)/,
    "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(@constitution), 0)}<!-- (#conBonus) -->"))
  end

  def parse_intelligence(document)
    return parse_wisdom(document.gsub(/((\d\d<!-- \(#intBonus\) -->|\d<!-- \(#intBonus\) -->)|<!-- \(#intBonus\) -->)/,
    "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(@intelligence), 0)}<!-- (#intBonus) -->"))
  end

  def parse_wisdom(document)
    return parse_charisma(document.gsub(/((\d\d<!-- \(#wisBonus\) -->|\d<!-- \(#wisBonus\) -->)|<!-- \(#wisBonus\) -->)/,
    "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(@wisdom), 0)}<!-- (#wisBonus) -->"))
  end

  def parse_charisma(document)
    return parse_strength_with_proficency(document.gsub(/((\d\d<!-- \(#chaBonus\) -->|\d<!-- \(#chaBonus\) -->)|<!-- \(#chaBonus\) -->)/,
    "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(@charisma), 0)}<!-- (#chaBonus) -->"))
  end

  def parse_strength_with_proficency(document)
    return parse_dexterity_with_proficency(document.gsub(/((\d\d<!-- \(#strBonus\+#proficiencyBonus\) -->|\d<!-- \(#strBonus\+#proficiencyBonus\) -->)|<!-- \(#strBonus\+#proficiencyBonus\) -->)/,
    "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(@strength), get_proficiency_bonus(@challenge_rating))}<!-- (#strBonus+#proficiencyBonus) -->"))
  end

  def parse_dexterity_with_proficency(document)
    return parse_constitution_with_proficency(document.gsub(/((\d\d<!-- \(#dexBonus\+#proficiencyBonus\) -->|\d<!-- \(#dexBonus\+#proficiencyBonus\) -->)|<!-- \(#dexBonus\+#proficiencyBonus\) -->)/,
    "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(@dexterity), get_proficiency_bonus(@challenge_rating))}<!-- (#dexBonus+#proficiencyBonus) -->"))
  end

  def parse_constitution_with_proficency(document)
    return parse_intelligence_with_proficency(document.gsub(/((\d\d<!-- \(#conBonus\+#proficiencyBonus\) -->|\d<!-- \(#conBonus\+#proficiencyBonus\) -->)|<!-- \(#conBonus\+#proficiencyBonus\) -->)/,
    "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(@constitution), get_proficiency_bonus(@challenge_rating))}<!-- (#conBonus+#proficiencyBonus) -->"))
  end

  def parse_intelligence_with_proficency(document)
    return parse_wisdom_with_proficency(document.gsub(/((\d\d<!-- \(#intBonus\+#proficiencyBonus\) -->|\d<!-- \(#intBonus\+#proficiencyBonus\) -->)|<!-- \(#intBonus\+#proficiencyBonus\) -->)/,
    "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(@intelligence), get_proficiency_bonus(@challenge_rating))}<!-- (#intBonus+#proficiencyBonus) -->"))
  end

  def parse_wisdom_with_proficency(document)
    return parse_charisma_with_proficency(document.gsub(/((\d\d<!-- \(#wisBonus\+#proficiencyBonus\) -->|\d<!-- \(#wisBonus\+#proficiencyBonus\) -->)|<!-- \(#wisBonus\+#proficiencyBonus\) -->)/,
    "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(@wisdom), get_proficiency_bonus(@challenge_rating))}<!-- (#wisBonus+#proficiencyBonus) -->"))
  end

  def parse_charisma_with_proficency(document)
    return parse_passive_perception(document.gsub(/((\d\d<!-- \(#chaBonus\+#proficiencyBonus\) -->|\d<!-- \(#chaBonus\+#proficiencyBonus\) -->)|<!-- \(#chaBonus\+#proficiencyBonus\) -->)/,
    "#{get_attribute_bonus_plus_proficiency_bonus(get_attribute_bonus(@charisma), get_proficiency_bonus(@challenge_rating))}<!-- (#chaBonus+#proficiencyBonus) -->"))
  end

  def parse_passive_perception(document)
    return parse_passive_perception_with_proficency(document.gsub(/((\d<!-- \(#passivePerception\) -->|\d\d<!-- \(#passivePerception\) -->)|<!-- \(#passivePerception\) -->)/,
    "#{get_passive_perception(get_attribute_bonus(@wisdom), 0)}<!-- (#passivePerception+#proficiencyBonus) -->"))
  end

  def parse_passive_perception_with_proficency(document)
    if document.include?("<!-- (#spellSaveDC:")
      return parse_spell_save_dc(document.gsub(/((\d<!-- \(#passivePerception\+#proficiencyBonus\) -->|\d\d<!-- \(#passivePerception\+#proficiencyBonus\) -->)|<!-- \(#passivePerception\+#proficiencyBonus\) -->)/,
    "#{get_passive_perception(get_attribute_bonus(@wisdom), get_proficiency_bonus(@challenge_rating))}<!-- (#passivePerception+#proficiencyBonus) -->"))
    else
      return document.gsub(/((\d<!-- \(#passivePerception\+#proficiencyBonus\) -->|\d\d<!-- \(#passivePerception\+#proficiencyBonus\) -->)|<!-- \(#passivePerception\+#proficiencyBonus\) -->)/,
    "#{get_passive_perception(get_attribute_bonus(@wisdom), get_proficiency_bonus(@challenge_rating))}<!-- (#passivePerception+#proficiencyBonus) -->")
    end
  end

  def parse_spell_save_dc(document)
    return parse_spell_attack_bonus(document.gsub(/((\d<!-- \(#spellSaveDC:...\) -->|\d\d<!-- \(#spellSaveDC:...\) -->)|<!-- \(#spellSaveDC:...\) -->)/,
    "#{
    get_spell_save(
      spell_save_attribute(get_spell_save_attribute(document)),
        get_proficiency_bonus(@challenge_rating))}<!-- (#spellSaveDC:#{get_spell_save_attribute(document)}) -->"))
  end

  def parse_spell_attack_bonus(document)
    return document.gsub(/((\d<!-- \(#spellAttackBonus:...\) -->|\d\d<!-- \(#spellAttackBonus:...\) -->)|<!-- \(#spellAttackBonus:...\) -->)/,
    "#{
    get_spell_attack(
      spell_save_attribute(get_spell_attack_attribute(document)),
        get_proficiency_bonus(@challenge_rating))}<!-- (#spellAttackBonus:#{get_spell_attack_attribute(document)}) -->")
  end
end

def update_stat_block(directory_file_name)
  stat_block_parser = StatBlockedParser.new()
  document = ""
  file = File.open(directory_file_name, "a+")

  file.each_line do |line|
    if line.match(/data-str=/)
      stat_block_parser.strength = stat_block_parser.get_attribute(line)
    elsif line.match(/data-dex=".+"/)
      stat_block_parser.dexterity = stat_block_parser.get_attribute(line)
    elsif line.match(/data-con=".+"/)
      stat_block_parser.constitution = stat_block_parser.get_attribute(line)
    elsif line.match(/data-int=".+"/)
      stat_block_parser.intelligence = stat_block_parser.get_attribute(line)
    elsif line.match(/data-wis=".+"/)
      stat_block_parser.wisdom = stat_block_parser.get_attribute(line)
    elsif line.match(/data-cha=".+"/)
      stat_block_parser.charisma = stat_block_parser.get_attribute(line)
    elsif line.match(/<h4>Challenge:<\/h4><p>.+<\/p>/) || line.match(/<h4>Challenge<\/h4><p>.+<\/p>/)
      stat_block_parser.challenge_rating = stat_block_parser.get_challenge_rate(line)
    end
    document << line
  end

  if stat_block_parser.challenge_rating != nil
    document = stat_block_parser.start_parse(document)
    file.truncate(0)

    file << document
    file.close()
  end
end

directory_file_name = ARGV[0]

if directory_file_name == nil
  begin
    puts "You did not enter a file to have the stat filled in. Would you like to fill in the stats for all character sheets in a directory? (y/n)"
    answer = gets.chomp
    answer = answer.downcase.strip
  end while answer != "y" && answer != "n"
  if answer == "n"
    begin
      puts "Please specify a file:"
      directory_file_name = gets.chomp
    end while !File.exist?(directory_file_name)
    update_stat_block(directory_file_name)
  elsif answer == "y"
    begin
      puts "Please specify a Directory:"
      directory_name = gets.chomp
    end while !Dir.exist?(directory_name)

    files_in_directory = Dir.glob("#{directory_name}/*.html")
    files_in_directory.each do |file|
      puts file.to_s
      update_stat_block(file)
    end
  end
else
  update_stat_block(directory_file_name)
end
