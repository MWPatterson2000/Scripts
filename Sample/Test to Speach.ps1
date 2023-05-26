# Create a speech synthesizer object
$synthesizer = New-Object -ComObject SAPI.SpVoice

# Set the volume and rate of the speech
$synthesizer.Volume = 100
$synthesizer.Rate = 0

# Speak the words "hello world"
$synthesizer.Speak("hello world")