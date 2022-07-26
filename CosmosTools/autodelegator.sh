#!/bin/bash

source $HOME/.profile
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
WITHOU_COLOR='\033[0m'


for (( ;; )); do
        echo -e "领取奖励。。。"
        echo -e "${PWDDD}\ny\n" | $PROJECT tx distribution withdraw-rewards ${VAL_ADDR} --chain-id ${CHAIN_ID} --from ${WALLETNAME} --commission --fees ${FEES}${DENOM} -y
for (( timer=12; timer>0; timer-- ))
        do
                printf "* sleep for ${RED_COLOR}%02d${WITHOUT_COLOR} sec\r" $timer
                sleep 1
        done
BAL=$($PROJECT q bank balances ${DEL_ADDR} -o json | jq -r '.balances | .[].amount')
        BAL=$(($BAL- 500))
echo -e "余额: ${GREEN_COLOR}${BAL}${WITHOU_COLOR} ${DENOM}\n"
        echo -e "质押全部\n"
if (( BAL > 500 )); then
            echo -e "${PWDDD}\n${PWDDD}\n" | $PROJECT tx staking delegate ${VAL_ADDR} ${BAL}${DENOM} --from ${DEL_ADDR} --chain-id ${CHAIN_ID} --fees ${FEES}${DENOM} -y
        else
                                echo -e "余额: ${GREEN_COLOR}${BAL}${WITHOU_COLOR} $DENOM BAL < 0 ((((\n"
        fi
for (( timer=${DELAY}; timer>0; timer-- ))
        do
            printf "* sleep for ${RED_COLOR}%02d${WITHOU_COLOR} sec\r" $timer
            sleep 1
        done
done
