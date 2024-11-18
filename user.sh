# before calling a function, it has to be sourced. here it is being sourced from common.sh.
# information is inherited from common.sh and during execution of this script, information from common.sh is substituted (made available).
# this is not the same as the file being executed.
# to execute, you can use bash <filename.sh>
# if the common.sh exists in another directory, provide the absolute pathname of the file
# the value for variables (which were defined in common.sh) component and app_path are defined in the files wherever they are needed for execution.

source common.sh
component=user
app_path=/app

NODEJS
