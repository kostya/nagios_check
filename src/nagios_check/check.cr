# class Nagios::Bla < Nagios::Check
#   def execute
#     x = 10
#     msg = "x #{x}"
#     if x < 1
#       crit msg
#     elsif x < 5
#       warn msg
#     else
#       ok msg
#     end
#   end
# end

# Nagios::Bla.check => {Nagios::OK, "x 10"}
# Nagios::Check.run("bla") => {Nagios::OK, "x 10"}

class Nagios::Check
  @@checks = {} of String => Nagios::Check

  getter check_name, started_at

  # macro inherited
  #   @@checks[self.class.check_name] = self.class
  # end

  # def self.run(method_name, params = {} of String => String)

  # end

  def initialize(@params = {} of String => String)
    @started_at = Time.now
    @check_name = self.class.check_name
    @ok = [] of String
    @crit = [] of String
    @warn = [] of String
    @other = [] of String
  end

  def self.check_name
    self.name.underscore.split("::").last
  end

  def result
    errors = message_prefix + (@crit + @warn + @other).join("; ")

    res = if @crit.any?
            {Nagios::CRIT, errors}
          elsif @warn.any?
            {Nagios::WARN, errors}
          elsif @other.any?
            {Nagios::OTHER, errors}
          else
            @ok = ["OK"] if message_prefix.empty? && @ok.empty?
            {Nagios::OK, message_prefix + @ok.join("; ")}
          end

    res
  end

  def message_prefix
    ""
  end

  def check
    begin
      execute
    rescue ex
      if msg = ex.message
        other "Exception: " + msg
      end
    end

    result
  end

  def self.check(params = {} of String => String)
    new(params).check
  end

  def execute
    raise "implement me"
  end

  macro add_check(name, res_name)
    def {{ name.id }}(msg)
      if yield
        @{{ res_name.id }} << msg
      end
    end

    def {{ name.id }}(msg)
      @{{ res_name.id }} << msg
    end
  end

  add_check "ok", "ok"
  add_check "crit", "crit"
  add_check "error", "crit"
  add_check "critical", "crit"
  add_check "other", "other"
  add_check "warn", "warn"
  add_check "warning", "warn"

  macro params(*names)
    {% for name in names %}
      def {{ name.id }}
        @params[{{name.id.stringify}}]?
      end
    {% end %}
  end

  def tresholds(method, w, e, &block)
    res = send(method)
    msg = block[res]
    if e && res >= e
      crit msg
    elsif w && res >= w
      warn msg
    else
      ok msg
    end
  end
end
