SHServer Cookbook
=============================
This Cookbook is used to setup a Self Healing Solution for an existing monitored infrastructure. 
It consists of two essential components: Self healing server & Self healing clients.

The cookbook consists of two recipes which should be used to deploy these components:
- Self healing server deployment: `SHServer`

Requirements
------------
Operating System: centos

#### Dependencies
The cookbook depends on the below cookbooks:
- `windows`
- `chef_handler`

Attributes
----------

#### SHServver::SHServer
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['SHServer']['pull_req_time']</tt></td>
    <td>Number</td>
    <td>Time interval to fetch data from Nagios (in minutes)</td>
    <td><tt>5</tt></td>
  </tr>
  <tr>
    <td><tt>['SHServerr']['healingscript_repo_name']</tt></td>
    <td>String</td>
    <td>Name of the healing script repository</td>
    <td><tt>Self-Healing-Script</tt></td>
  </tr>
  <tr>
    <td><tt>['SHServer']['healingscript_repo_url']</tt></td>
    <td>String</td>
    <td>URL for the healing script repository</td>
    <td><tt>github.wdf.sap.corp/GLDS-SM/Self-Healing-Script.git</tt></td>
  </tr>
  <tr>
    <td><tt>['SHServer']['hrepo_username']</tt></td>
    <td>String</td>
    <td>Github username to fetch latest scripts from repository</td>
    <td><tt>-</tt></td>
  </tr>
  <tr>
    <td><tt>['SHServer']['hrepo_password']</tt></td>
    <td>String</td>
    <td>Github password to fetch latest scripts from repository</td>
    <td><tt>-</tt></td>
  </tr>
  <tr>
    <td><tt>['SHServer']['rules_file_name']</tt></td>
    <td>String</td>
    <td>Name of the rules file that is used for making healing decisions</td>
    <td><tt>healingrules_v2.nb</tt></td>
  </tr>
</table>

Usage
-----
#### SHServer::SHServer
This recipe is used to setup the SHServer.

Just include `SHServer` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[SHServer]"
  ]
}
```
License and Authors
-------------------
Authors: Copyright 2016, Opex Software
