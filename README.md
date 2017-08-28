# Step 1: Clone sim-grid project

Checkout sim-grid project to your local directory:

```bash
cd <local directory>
git clone https://github.com/henrrich/sim-grid.git
```

# Step 2: Setup SSH public key authentication to target grid hub host

Ansible uses SSH by default to connect to remote server. SSH public key authentication is a recommended way of setting up SSH connection from your local Ansible control host to the target remote host.

```bash
ssh-keygen -t rsa ### generate ssh key
scp ~/.ssh/id_rsa.pub <remote username>@<remote host>: ### copy public key to remote host
```

SSH to remote host and check if file `~/.ssh/authorized_keys` exists. If it does not exist, run the following commands:

```bash
mkdir -p ~/.ssh 
touch ~/.ssh/authorized_keys
```

Append new public key to the remote key file:

```bash
cat ~/id_rsa.pub >> ~/.ssh/authorized_keys ### append new key
more ~/.ssh/authorized_keys ### check if the new key is added
rm ~/id_rsa.pub ### remove the temporary key file transferred
```

Quit from SSH and try to SSH to the remote host again to verify that no password is required when SSH to remote host.

# Step 3: Add target grid hub host as Ansible inventory

Add the target grid hub host in Ansible project's `production` file under the `hub` group:

```
[hub]
<target grid hub host IP> ansible_connection=ssh ansible_user=<SSH username>
```

# Step 4: Run Ansible playbook to setup grid hub

Execute the Ansible playbook so that the grid will be automatically deployed onto target remote host:

```bash
cd <sim-grid root directory>
ansible-playbook -i production playbooks/hub_deploy.yml
```

After the playbook is finished, logon to the remote grid hub host, the following files should be created under `$HOME/gridhub` folder of the SSH user:

gridhub:

* hubconfig.json
* log4j.properties
* start_grid.sh
* stop_grid.sh
* appium-grid.jar

## Start and Stop Grid Hub:

To launch the grid hub, run the following Ansible playbook command:

```bash
ansible-playbook -i production playbooks/hub_start.yml
```

Open the following URL in your browser, an empty Selenium grid website should be displayed:

[http://target_grid_hub_host_IP:4444/grid/console](http://target_grid_hub_host_IP:4444/grid/console)

 
To stop the grid hub, run the following Ansible playbook command:

```bash
ansible-playbook -i production playbooks/hub_stop.yml
```

## Grid Hub Upgrade:

The appium grid hub implementation is stored in a git repo: [https://github.com/henrrich/appium-grid.git](https://github.com/henrrich/appium-grid.git)

If modification is needed in the implementation, checkout this project, apply the change and run `mvn clean package`. A self contained jar file `appium-grid-1.0.0.1-SNAPSHOT-jar-with-dependencies.jar` will be generated under the project's `target` folder.

Replace the `roles/hub/files/appium-grid-1.0.0.1-SNAPSHOT-jar-with-dependencies.jar` file in the Ansible project with the newly generated one and run the following commands when no execution is ongoing:

```bash
cd <sim-grid root directory>
ansilbe-playbook -i production playbooks/hub_stop.yml ### stop the grid hub
ansible-playbook -i production playbooks/hub_deploy.yml ### re-deploy grid hub
ansible-playbook -i production playbooks/hub_start.yml ### restart grid hub
```

## Grid Node Setup:

To setup grid node environment on your workstation or laptop, please ensure Appium 1.6+ is installed.

The sim-grid project can also be used to generate grid node configuration and start/stop scripts for starting/stopping the Appium server instance connected to a specified device. Run the following command to generate grid node configuration file and start/stop scripts for a connected device:

```bash
cd <sim-grid project root directory>
ansible-playbook -i production playbooks/node_generate_config.yml --extra-vars "target_dir=<directory where config file and scripts will be generated> device_name=<device name e.g. 'iPhone 6 Plus'> platform_name=<iOS | Android> platform_version=<iOS or Android version e.g. 10.2> udid=<device udid> host=<IP address of grid node host, Note: localhost/127.0.0.1 should not be used here> port=<Appium port, different ports should be used if running multiple Appium instances> hub_host=<IP address of grid hub host> hub_port=<port of grid hub host>"
```

The following files will be generated under the specified target directory:

* nodeconfig_<device name>.json ### node config file for grid node instance
* start_<device name>.sh ### start script for Appium grid node instance that manages the specified device
* stop_<device name>.sh ### stop script for Appium grid node instance that manages the specified device

When the device is connected, use the generated start script to launch the Appium grid node instance:

```bash
./start_<device name>.sh
```

The Appium grid node instance will register itself to the grid hub. You should be able to see the device in the grid hub console:

[http://target_grid_hub_host_IP:4444/grid/console](http://target_grid_hub_host_IP:4444/grid/console)

To stop the Appium grid node instance, run the generated stop script:

```bash
./stop_<device name>.sh
```