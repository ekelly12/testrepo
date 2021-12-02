ulimit -c unlimited \
&& sudo sysctl -w kernel.core_pattern=/tmp/core/%e-%p-%s-%u.core
