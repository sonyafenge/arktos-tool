#############
local machines
#############

kubectl --kubeconfig /home/sonyafenge/go/src/k8s.io/arktos/test/kubemark/resources/kubeconfig.kubemark proxy 8888

Use another terminal window to run:
curl http://127.0.0.1:8001/debug/pprof/profile -o prof.cpu
go tool pprof prof.cpu
(pprof) top10

###############
Additional analysis options
###############

go tool pprof -top prof.cpu15000
go tool pprof -png prof.cpu15000 > cpu.png



#####################
Profile path
#####################

There are 7 places you can get profiles in the default webserver: the ones mentioned above
* http://localhost:8001/debug/pprof/goroutine 
* http://localhost:8001/debug/pprof/heap 
* http://localhost:8001/debug/pprof/threadcreate 
* http://localhost:8001/debug/pprof/block 
* http://localhost:8001/debug/pprof/mutex 
and also 2 more: the CPU profile and the CPU trace.
* http://localhost:8001/debug/pprof/profile 
* http://localhost:8001/debug/pprof/trace?seconds=5 


################
collecting files
#################

curl http://127.0.0.1:8001/debug/pprof/profile -o prof.cpu2500
curl http://127.0.0.1:8001/debug/pprof/heap -o prof.heap2500
curl http://127.0.0.1:8001/debug/pprof/goroutine  -o prof.goroutine2500
curl http://127.0.0.1:8001/debug/pprof/mutex  -o prof.mutex2500
curl http://127.0.0.1:8001/debug/pprof/block  -o prof.block2500
curl http://127.0.0.1:8001/debug/pprof/threadcreate  -o prof.threadcreate2500

curl http://127.0.0.1:8001/debug/pprof/profile?seconds=5  -o prof.cpu5000node35958pod5
