# quickfix-formula
This repository contains state files that are run manually.  
The state files can be run on every node with salt master **edu-foreman.topicusonderwijs.local** or **intern-foreman.edu.codes**.

Getting started:
1. Create a directory with your name.
2. Create a .sls file.
3. Run the sls file. For example: 

```salt edu-foreman.topicusonderwijs.local state.sls dana/example test=true```
