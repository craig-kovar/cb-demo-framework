#@ Run fakeit to generate sample data
#^ 3rd Party
PROMPT~Enter path of fakeit configuration yaml~FAKECONF
PROMPT~Enter output directory~FAKEOUT
PROMPT~Enter number of records to generate~FAKENUM
EXEC~fakeit directory -c {{FAKENUM}} -f json --verbose {{FAKEOUT}} {{FAKECONF}}
