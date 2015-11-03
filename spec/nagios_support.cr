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

class Nagios::GenCheck1 < Nagios::Check
  params :dir, :to

  def red(x = 10)
    x / 10.0
  end

  gen_check :red

  def execute
    upto = (to || 10).to_i
    if dir == "right"
      (0..upto).each { |param| check_red(param, ok: {0.9, 1.0}, warn: {0.3, 0.9}, crit: {0.0, 0.3}) }
    else
      (0..upto).each { |param| check_red(param, ok: {0.0, 0.7}, warn: {0.7, 0.9}, crit: {0.9, 1.0}) }
    end
  end
end

class Nagios::GenCheck2 < Nagios::Check
  params :r

  def red(x)
    (r || 0.1).to_f
  end

  gen_check :red

  def execute
    check_red ok: 0.1, warn: 0.2, crit: 0.3
  end
end

class Nagios::GenCheck3 < Nagios::Check
  params :r

  def red(x)
    r ? true : false
  end

  gen_check :red

  def execute
    check_red ok: true, crit: false
  end
end
