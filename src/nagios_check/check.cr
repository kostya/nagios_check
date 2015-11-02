class Nagios::Check
  getter check_name, started_at

  def self.run(method_name, params = {} of String => String)
    if kl = subclasses.find { |s| s.check_name == method_name }
      kl.check(params)
    else
      {Nagios::OTHER, "Not found class for '#{method_name}'"}
    end
  end

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

  macro def self.subclasses : Array(Nagios::Check.class)
    {{ Nagios::Check.subclasses }}
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
      other "Exception: " + ex.message.to_s
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

  def tresholds(method : ->, w, e, &block)
    res = method.call
    msg = block[res] || res.inspect

    if e && res >= e
      crit msg
    elsif w && res >= w
      warn msg
    else
      ok msg
    end
  end

  def tresholds(method, w, e)
    thresholds(method, w, e) { nil }
  end
end
