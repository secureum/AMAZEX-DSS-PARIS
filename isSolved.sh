for (( V=1; V<=8; V++ ))
do
    printf "\n================== Challenge$V ==============================\n\n"
    printf "Checking if Challenge $V has been solved...\n"
    forge test --match-path test/Challenge$V.t.sol
done