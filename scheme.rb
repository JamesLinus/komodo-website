require 'json'

class Scheme
  
  @@colors = [
    [
        ["CommonStyles", "default_fixed", "back"],
        ["CommonStyles", "default_proportional", "back"]
    ],
    [
        ["CommonStyles", "default_fixed", "fore"],
        ["CommonStyles", "default_proportional", "fore"]
    ],
    [["CommonStyles", "comments", "fore"],],
    [["CommonStyles", "keywords", "fore"],],
    [["CommonStyles", "strings", "fore"],],
    [["CommonStyles", "classes", "fore"],],
    [
        ["CommonStyles", "variables", "fore"],
        ["LanguageStyles", "Python", "variables", "fore"],
        ["LanguageStyles", "Ruby", "variables", "fore"],
        ["LanguageStyles", "Tcl", "variables", "fore"],
        ["LanguageStyles", "PHP", "variables", "fore"]
    ],
    [["CommonStyles", "numbers", "fore"],],
    [["CommonStyles", "operators", "fore"],],
    [["CommonStyles", "identifiers", "fore"],]
  ]
  
  def initialize(ksf)
    ksf = JSON.parse(ksf)
    
    if ksf.has_key? "exports"
      ksf = ksf["exports"]
    end
    
    @fg = []
    @@colors.each do |options|
        options.each do |option|
            c = self._get(option, ksf)
            if c
                @fg.push self.hex(c)
                break
            end
        end
    end
    @bg = @fg.shift
  end
  
  def bg
    @bg
  end
  
  def fg
    @fg
  end
  
  def hex(value)
      value = ((value & 0xFF0000) >> 16) +
          (value & 0x00FF00) +
         ((value & 0xFF) << 16)
      return "#" + ("0" + ((value & 0xFF0000) >> 16).to_s(16))[-2..-1] +
               ("0" + ((value &   0xFF00) >>  8).to_s(16))[-2..-1] +
               ("0" + ((value &   0xFF)   >>  0).to_s(16))[-2..-1]
  end
  
  def _get(select, ob)
      r = ob
      select.each() do |k|
          unless r.has_key? k
              return false
          end
          r = r[k]
      end
      return r
  end
end