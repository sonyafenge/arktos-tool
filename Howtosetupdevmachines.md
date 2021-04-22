* Install cloud SDK: https://cloud.google.com/sdk/docs/downloads-interactive#linux
* install docker , using command
https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce  ensure docker and gcloud are under same folder, otherwise startkubemark will failed with permission denied when docker push to gcr.io
* Add current user to docker group to unblock access deny issue, need restart vm after these command
            * sudo groupadd docker
            * sudo usermod -aG docker $USER
* Install go
            * wget https://dl.google.com/go/go1.12.9.linux-amd64.tar.gz
            * sudo tar -C /usr/local -xzf go1.12.9.linux-amd64.tar.gz
            * Edit $HOME/.profile: add below
				export PATH=$PATH:/usr/local/go/bin
			source $HOME/.profile:
* Install python if python: command not found
		sudo apt install python
* Install build-essential to avoid gcc error
		sudo apt install build-essential
* Install jq
		sudo apt install jq
* Install bazel (use 0.26.1 for now):
		Install: https://docs.bazel.build/versions/master/install-ubuntu.html - follow instruction in section "Using the binary installer" Install containerd
	$ wget https://storage.googleapis.com/cri-containerd-release/cri-containerd-1.1.8.linux-amd64.tar.gz
	$ sudo tar --no-overwrite-dir -C / -xzf cri-containerd-1.1.8.linux-amd64.tar.gz
	$ rm cri-containerd-1.1.8.linux-amd64.tar.gz
	$ sudo systemctl start containerd


#########
Update open files number for large scale testing

Ulimit -a -   check all limit information
Ulimit -n -   check open files limitation
##########

#####for ubuntu1.18.4
https://askubuntu.com/questions/1049058/how-to-increase-max-open-files-limit-on-ubuntu-18-04

The only file that needed to be changed was /etc/security/limits.conf. Appending the line * - nofile 65535 to that file and re-login in did the trick:
$ ulimit -sn
65535

######For ubuntu1.16.4
 https://medium.com/@muhammadtriwibowo/set-permanently-ulimit-n-open-files-in-ubuntu-4d61064429a
