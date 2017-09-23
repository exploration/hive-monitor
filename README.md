# HIVE Monitor

This app subscribes to real-time Atom updates from [HIVE](https://bitbucket.org/explo/hive-2), and can run scripts on the local machine in response to them. You would use it to avoid having to long-poll HIVE's REST API and instead get results in closer to real-time.

The application can also run local scripts, in a similar way to cron, which makes it easier to keep all synchronization in one area. See `hive_monitor.ex` for details of how to set that up.
