# before calling a function, it has to be sourced. here it is being sourced from common.sh.
# information is inherited from common.sh and during execution of this script, information from common.sh is substituted (made available).
# this is not the same as the file being executed.
# to execute, you can use bash <filename.sh>
# if the common.sh exists in another directory, provide the absolute pathname of the file
# the component variable is defined individually for each service and is being called in the common.sh file
# the values for variables (which were defined in common.sh) component, app_path and schema_setup are defined in the files wherever they are needed for execution.

source common.sh
component=catalogue
app_path=/app
schema_setup=mongo

NODEJS

