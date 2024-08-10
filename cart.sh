source common.sh #before calling a function, it has to be sourced. here it is being sourced from common.sh. information is inherited from common.sh and while execution of this script, information from common.sh is substituted (made available)
#if the common.sh exists in another directory, provide the absolute pathname of the file
component=cart # the component variable is defined individually for each service and is being called in the common.sh file
app_path=/app

NODEJS
