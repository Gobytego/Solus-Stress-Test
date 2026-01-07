#!/bin/bash

# 1. Solus Dependency Check
install_if_missing() {
    if ! command -v $1 &> /dev/null; then
        echo "Installing $1 via eopkg..."
        sudo eopkg it $1 -y
    fi
}

install_if_missing stress-ng
install_if_missing btop
install_if_missing tmux

# 2. Setup Variables
CORES=$(nproc)
MAX_INDEX=$((CORES - 1))
HALF_CORES=$((CORES / 2))
EVEN_CORES=$(seq 0 2 $MAX_INDEX | paste -sd, -)
ODD_CORES=$(seq 1 2 $MAX_INDEX | paste -sd, -)

# 3. User Input (Run once in main terminal)
if [ -z "$1" ]; then
    echo "--- Solus System Stress Setup ---"
    read -p "Enter duration per test in seconds [Default 20]: " USER_TIME
    read -p "Enter number of cycles to run [Default 1]: " USER_CYCLES
    read -p "Run Memory Stress tests at the end of each cycle? (y/N): " USER_MEM
    
    # Defaults
    DUR=${USER_TIME:-20}
    CYC=${USER_CYCLES:-1}
    RUN_MEM=$(echo "${USER_MEM:-n}" | tr '[:upper:]' '[:lower:]' | cut -c1)

    # Launch tmux session
    tmux new-session -d -s stress_test "btop"
    echo "Initializing graphical monitor..."
    sleep 3
    
    # btop Toggles: If NO memory test, hide Memory Box (2). 
    # Always hide Disks (3), Net (4), and Procs (0).
    BTOP_KEYS="340" 
    [[ "$RUN_MEM" != "y" ]] && BTOP_KEYS="2340"

    for (( i=0; i<${#BTOP_KEYS}; i++ )); do
        tmux send-keys -t stress_test "${BTOP_KEYS:$i:1}"
        sleep 0.2
    done
    
    # Restart script inside tmux with arguments
    tmux split-window -v -p 35 "$0 run $DUR $CYC $RUN_MEM"
    tmux attach-session -t stress_test
    exit
fi

DUR=$2
CYC=$3
RUN_MEM=$4

# --- 4. START STRESS TESTS ---
clear
for ((i=1; i<=CYC; i++)); do
    echo "---------------------------------------------------"
    echo " CYCLE $i OF $CYC"
    echo "---------------------------------------------------"
    
    echo "--- Test 1: Sequential Core Sweep (1-by-1) ---"
    for core in $(seq 0 $MAX_INDEX); do
        echo "Stressing Core $core..."
        stress-ng --cpu 1 --taskset $core --timeout ${DUR}s --quiet
    done

    echo "--- Test 2: Full System CPU Load (100%) ---"
    stress-ng --cpu $CORES --timeout ${DUR}s

    echo "--- Test 3: Even Cores Alternation ---"
    stress-ng --cpu $HALF_CORES --taskset $EVEN_CORES --timeout ${DUR}s
    
    echo "--- Test 4: Odd Cores Alternation ---"
    stress-ng --cpu $HALF_CORES --taskset $ODD_CORES --timeout ${DUR}s

    # Memory tests moved to the end of the cycle
    if [[ "$RUN_MEM" == "y" ]]; then
        echo "--- Test 5: Memory Stress (80% Physical RAM) ---"
        stress-ng --vm 2 --vm-bytes 80% --vm-populate --vm-keep --timeout ${DUR}s

        echo "--- Test 6: Combined CPU & Memory Burn ---"
        stress-ng --cpu $CORES --vm 2 --vm-bytes 50% --vm-populate --timeout ${DUR}s
    else
        echo "--- Skipping Memory Tests ---"
    fi

    echo "Cycle $i complete."
    sleep 1
done

echo "---------------------------------------------------"
echo "All $CYC cycles complete. Press any key to exit."
read -n 1
tmux kill-session -t stress_test
