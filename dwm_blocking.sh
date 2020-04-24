#!/usr/bin/env sh

bar=''

stat=''    
stat+="$(memory) $bar"
stat+="$(cpu) $bar"
stat+="$(battery) $bar"
stat+="$(printf '🔆 %.0f%% %s' $(light) $bar)"
stat+="$(volume) $bar"
stat+="$(internet) $bar"
stat+="$(mailbox) $bar"
stat+="$(clock)"
xsetroot -name "$stat »"
sleep 10 
