require "./spec_helper"

class Nagios::Bla < Nagios::Check
  params :s

  def execute
    crit "a1" if s == "crit" || s == "crit_warn"
    warn "a2" if s == "warn" || s == "crit_warn"
    raise "a3" if s == "raise"
    other "a4" if s == "other"
    ok "a5"
  end
end

# block parameter
class Nagios::BlockObj < Nagios::Check
  params :s

  def execute
    crit("2") { s == "2" }
    ok "1"
  end
end

class Nagios::Prefix < Nagios::Check
  params :s

  def message_prefix
    "some "
  end

  def execute
    s == "1" ? crit("1") : ok("2")
  end
end

class Nagios::Tresh < Nagios::Check
  # params :s, :c

  # def some_m
  #   if ss = s
  #     ss.to_i
  #   else
  #     0
  #   end
  # end

  # def criti
  #   if cc = c
  #     cc.to_i
  #   else
  #     0
  #   end
  # end

  # def execute
  #   tresholds(->() { some_m }, 5, criti) { |x| "msg #{x}" }
  # end
end
