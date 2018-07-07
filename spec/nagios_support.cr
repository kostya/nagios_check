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

class Nagios::BlaOutputOk < Nagios::Check
  params :s

  def always_output_ok?
    true
  end

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

class Nagios::FastCheck1 < Nagios::Check
  params :dir, :to

  def red(x = 10)
    x / 10.0
  end

  def execute
    upto = (to || 10).to_i
    if dir == "right"
      (0..upto).each { |param| chk(red(param), ok: {0.9, 1.0}, warn: {0.3, 0.9}, crit: {0.0, 0.3}) }
    else
      (0..upto).each { |param| chk(red(param), ok: {0.0, 0.7}, warn: {0.7, 0.9}, crit: {0.9, 1.0}) }
    end
  end
end

class Nagios::FastCheck2 < Nagios::Check
  params :r

  def red
    (r || 0.1).to_f
  end

  def execute
    chk red, ok: 0.1, warn: 0.2, crit: 0.3
  end
end

class Nagios::FastCheck3 < Nagios::Check
  params :r

  def red
    r ? true : false
  end

  def execute
    chk red, ok: true, crit: false
  end
end

class Nagios::FastCheckArray < Nagios::Check
  params :r

  def red
    (r || 11).to_i
  end

  def execute
    chk red, ok: [1, 5, 7], crit: [8, 12, 22]
  end
end

class Nagios::FastCheckRange < Nagios::Check
  params :r

  def red
    (r || 12).to_i
  end

  def execute
    chk red, ok: 0..12, crit: 15..22
  end
end

class Nagios::FastCheckValue < Nagios::Check
  def execute
    chk 1.0, ok: 1.0
  end
end

class Nagios::FastCheckValue2 < Nagios::Check
  def execute
    chk "jopa", ok: "jpoa"
  end
end

class Nagios::FastCheckValue3 < Nagios::Check
  def execute
    a = 2
    chk a, warn: 2
  end
end

class Nagios::LimitsCheck < Nagios::Check
  params :r

  def red
    (r || 0.5).to_f
  end

  def execute
    chk red, limits: {0.0, 0.6, 0.9, 1.0}
  end
end

class Nagios::BackLimitsCheck < Nagios::Check
  params :r

  def red
    (r || 0.5).to_f
  end

  def execute
    chk red, limits: {1.0, 0.9, 0.6, 0.0}
  end
end
