# NagiosCheck

Dsl to create nagios checks, inside application.

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  nagios_check:
    github: kostya/nagios_check
```


## Usage


```crystal
require "nagios_check"

class Nagios::Blah < Nagios::Check
  def execute
    x = SomeClass.some_method
    if x < 10
      crit "some_method < 10"
    elsif x < 20
      warn "some_method < 20"
    else
      ok "ok"
    end
  end
end

status, message = Nagios::Check.run("blah")
```

## FastCheck


```crystal
class Nagios::Blah < Nagios::Check
  def some_measure(arg)
    rand + arg
  end

  def execute
    # method check(name, value, limits)
    check "some_measure(0)", some_measure(0), ok: {0, 0.5}, warn: {0.5, 0.7}, crit: {0.7, 1.0}

    # macro chk(expression, limits)
    chk some_measure(1), ok: {0, 0.5}, warn: {0.5, 0.7}, crit: {0.7, 1.0}
  end
end
```
