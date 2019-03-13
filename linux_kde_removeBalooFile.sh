#!/bin/sh

killall baloo_file ; mv /usr/bin/baloo_file /usr/bin/baloo_file.bak ; echo '#!/bin/sh' > /usr/bin/baloo_file
