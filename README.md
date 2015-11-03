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
    x = some_method
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
