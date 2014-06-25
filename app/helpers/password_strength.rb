class PasswordStrength
  
  def self.calcStrength(password)
    
    strength = ""
    
    if password =~ /^.*(?=.{6,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).*$/
      strength = "strong"
    elsif password =~ /^.*(?=.{6,})(?=.*[a-z])(?=.*[A-Z]).*$/
      strength = "medium"
    else
      strength = "weak"
    end
    
    return strength
  end
  
end