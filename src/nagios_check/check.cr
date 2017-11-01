class Nagios::Check
  getter check_name, started_at

  def self.run(method_name, params = {} of String => String)
    if klass = subclasses.find { |s| s.check_name == method_name }
      klass.check(params)
    else
      {Nagios::OTHER, "Not found class for '#{method_name}'"}
    end
  end

  @started_at : Time
  @check_name : String

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

  def self.subclasses
    {{ @type.subclasses }}
  end

  def result
    errors = [] of String
    errors << @crit.join("; ") if @crit.any?
    errors << @warn.join("; ") if @warn.any?
    errors << @other.join("; ") if @other.any?
    errors = message_prefix + errors.join(" \\ ")

    if @crit.any?
      {Nagios::CRIT, errors}
    elsif @warn.any?
      {Nagios::WARN, errors}
    elsif @other.any?
      {Nagios::OTHER, errors}
    else
      @ok = ["OK"] if message_prefix.empty? && @ok.empty?
      {Nagios::OK, message_prefix + @ok.join("; ")}
    end
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

  macro chk(call, ok = nil, warn = nil, crit = nil, limits = nil)
    {% if call.is_a?(Call) %}
      arguments = Tuple.new({{call.args.splat}})
      {% call = "#{call.receiver}#{".".id if call.receiver}#{call.name}" %}
      str = "#{ {{call}} }#{"(" + arguments.map(&.inspect).join(", ") + ")" if arguments.any?}"
      res = {{ call.id }}(*arguments)
    {% else %}
      str = nil
      res = {{ call }}
    {% end %}
    check(str, res, {{ ok }}, {{ warn }}, {{ crit }}, {{ limits }})
  end

  def check(name : String?, res, ok = nil, warn = nil, crit = nil, limits = nil)
    msg = name ? name + ":#{res}" : res.to_s

    ok msg

    if limits && limits.is_a?(Tuple) && limits.size == 4
      a1, a2, a3, a4 = limits
      if a1 < a2 < a3 < a4
        ok = {a1, a2}
        warn = {a2, a3}
        crit = {a3, a4}
      elsif a1 > a2 > a3 > a4
        ok = {a2, a1}
        warn = {a3, a2}
        crit = {a4, a3}
      else
        raise "parameters should be ordered <#{a1}, #{a2}, #{a3}, #{a4}>"
      end
    end

    {% for chk in %w(crit warn ok) %}
      cond = if {{ chk.id }}.is_a?(Tuple)
        left, right = {{ chk.id }}
        res >= left && res <= right
      elsif {{ chk.id }}.is_a?(Array)
        {{ chk.id }}.includes?(res)
      elsif {{ chk.id }}.is_a?(Range)
        {{ chk.id }}.includes?(res)
      elsif !{{ chk.id }}.nil?
        res == {{ chk.id }}
      end
      if {{ "!".id if chk == "ok" }}cond
        {{ chk == "ok" ? "other".id : chk.id }} msg
        return
      end
    {% end %}
  end
end
