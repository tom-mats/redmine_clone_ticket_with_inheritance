# Clone ticket with Inheritance

## Overview

This plugins copies tickets automatically to the specified project and tracker when the status is changed.
We have implemented to manage testcases and corresponding test results on Redmine as tickets.

## Supported

* Enable/Disable the plugin per project.
* Specify the dst project and tracker per project.
* Copy with/without attachments, relation issue and children tickets.
* Rollback status and/or fixed version when the ticket is copied.
* Create the used category automatically to dst project.


## Unimplemented

* Specify the trackers to copy ticket.
* Specify the status to copy ticket.
  * Currently, all tickets are copied when status is changed.

## License

Apache License Ver. 2
