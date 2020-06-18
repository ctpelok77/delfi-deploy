Bootstrap: docker
From: ctpelok77/delfi:latest

%setup
    # Just for diagnosis purposes
    hostname -f > $SINGULARITY_ROOTFS/etc/build_host
%runscript
    # This will be called whenever the Singularity container is invoked
    python /workspace/delfi/plan-ipc.py --image-from-lifted-task $@

%post

%labels
Name        Delfi1 (winner of IPC2018, optimal track)
Description This planner uses an offline learned algorithm selector to choose the "best" planner online based on a abstract structure graph of the PDDL description of the planning task. In particular, the learning algorithm uses such graphs of a planning task, turns them into an image and uses the planner runtime to train a neural net. The learned model thus predicts runtime of planners on a given task and chooses a planner accordingly.
Authors     Michael Katz <michael.katz1@ibm.com>, Shirin Sohrabi <ssohrab@us.ibm.com>, Horst Samulowitz <samulowitz@us.ibm.com>, and Silvan Sievers <silvan.sievers@unibas.ch>
