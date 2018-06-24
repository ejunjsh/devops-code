#!/bin/sh
handle_exit_code() {
  ERROR_CODE="$?";
  printf -- "an error occurred. cleaning up now... ";
  # ... cleanup code ...
  printf -- "DONE.\nExiting with error code ${ERROR_CODE}.\n";
  exit ${ERROR_CODE};
}
trap "handle_exit_code" EXIT;
# ... actual script...
