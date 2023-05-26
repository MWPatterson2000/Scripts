################################
# Company: Quest Software
# Author: Gary Broadwater
################################
$q = new-object -com SAPI.SpVoice
$q.speak($args)
$q = $null