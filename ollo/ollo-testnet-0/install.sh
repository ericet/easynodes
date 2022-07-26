#!/bin/bash

while true
do

# Logo

echo "============================================================"
curl -s https://raw.githubusercontent.com/ericet/easynodes/master/logo.sh | bash
echo "============================================================"


source ~/.profile

PS3='选择一个操作 '
options=(
"安装必要的环境" 
"安装节点(快速同步)" 
"创建钱包"
"节点日志" 
"查看节点状态" 
"水龙头获得测试币" 
"钱包余额" 
"创建验证人" 
"查看验证人"
"退出")
select opt in "${options[@]}"
               do
                   case $opt in
                   
"安装必要的环境")
echo "============================================================"
echo "准备开始。。。"
echo "============================================================"

#INSTALL DEPEND
echo "============================================================"
echo "Update and install APT"
echo "============================================================"
sleep 3
sudo apt update && sudo apt upgrade -y && \
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

#INSTALL GO
echo "============================================================"
echo "Install GO 1.18.1"
echo "============================================================"
sleep 3
wget https://golang.org/dl/go1.18.1.linux-amd64.tar.gz; \
rm -rv /usr/local/go; \
tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz && \
rm -v go1.18.1.linux-amd64.tar.gz && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.profile && \
source ~/.profile && \
go version > /dev/null

echo "============================================================"
echo "服务器环境准备好了!"
echo "============================================================"
break
;;
            
"安装节点(快速同步)")
echo "============================================================"
echo "输入节点的名称:"
echo "============================================================"
                
read OLLONODE
OLLONODE=$OLLONODE
echo 'export OLLONODE='${OLLONODE} >> $HOME/.profile

echo "============================================================"
echo "输入钱包名称:"
echo "============================================================"
               
read OLLOWALLET
OLLOWALLET=$OLLOWALLET
echo 'export OLLOWALLET='${OLLOWALLET} >> $HOME/.profile
OLLOCHAIN=""atlantic-1""
echo 'export OLLOCHAIN='${OLLOCHAIN} >> $HOME/.profile
source $HOME/.profile

echo "============================================================"
echo "节点安装开始。。。"
echo "============================================================"

git clone https://github.com/OLLO-Station/ollo
cd ollo
make install

ollod init $OLLONODE --chain-id $OLLOCHAIN

ollod tendermint unsafe-reset-all --home $HOME/.ollo
rm $HOME/.ollo/config/genesis.json
wget -O $HOME/.ollo/config/genesis.json "https://raw.githubusercontent.com/OllO-Station/ollo/master/networks/ollo-testnet-0/genesis.json"

# config pruning
indexer="null"
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"

sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.ollo/config/config.toml
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.ollo/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.ollo/config/app.toml

wget -O $HOME/.ollo/config/addrbook.json "https://raw.githubusercontent.com/OllO-Station/ollo/master/networks/ollo-testnet-0/addrbook.json"
SEEDS=""
PEERS="2a8f0fada8b8b71b8154cf30ce44aebea1b5fe3d@145.239.31.245:26656,1173fe561814f1ecb8b8f19d1769b87cd576897f@185.173.157.251:26656,489daf96446f104d822fae34cd4aa7a9b5cebf65@65.21.131.215:26626,f43435894d3ae6382c9cf95c63fec523a2686345@167.235.145.255:26656,2eeb90b696ba9a62a8ad9561f39c1b75473515eb@77.37.176.99:26656,9a3e2725e02d1c420a5d500fa17ce0ef45ddc9e8@65.109.30.117:29656,91f1889f22975294cfbfa0c1661c63150d2b9355@65.108.140.222:30656,d38fcf79871189c2c430473a7e04bd69aeb812c2@78.107.234.44:16656,f795505ac42f18e55e65c02bb7107b08d83ad837@65.109.17.86:37656,6368702dd71e69035dff6f7830eb45b2bae92d53@65.109.57.161:15656" \
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.ollo/config/config.toml
SNAP_RPC="https://node.ollo.zone:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.ollo/config/config.toml
sudo systemctl restart ollod && journalctl -u ollod -f -o cat


tee $HOME/ollod.service > /dev/null <<EOF
[Unit]
Description=Ollo Testnet Daemon
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which ollod) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/ollod.service /etc/systemd/system/

# start service
sudo systemctl daemon-reload
sudo systemctl enable ollod
sudo systemctl restart ollod

echo "============================================================"
echo "节点安装成功!"
echo "============================================================"
break
;;


"创建钱包")
echo "============================================================"
echo "请保存助记词!"
echo "============================================================"
               
ollod keys add $OLLOWALLET
OLLOADDRWALL=$(ollod keys show $OLLOWALLET -a)
OLLOVAL=$(ollod keys show $OLLOWALLET --bech val -a)
echo 'export OLLOVAL='${OLLOVAL} >> $HOME/.profile
echo 'export OLLOADDRWALL='${OLLOADDRWALL} >> $HOME/.profile
source $HOME/.profile

echo "============================================================"
echo "钱包地址: $OLLOADDRWALL"
echo "验证人地址: $OLLOVAL"
echo "============================================================"
               
break
;;

"查看节点状态")
echo "============================================================"
echo "节点catching_up为false的时候继续下一步"
echo "============================================================"
echo "节点状态 = $(curl -s localhost:26657/status | jq .result | jq .sync_info)"
echo "区块高度 = $(ollod status 2>&1 | jq ."SyncInfo"."latest_block_height")"
echo "验证人状态 = $(ollod q slashing signing-info $(ollod tendermint show-validator))"
echo "============================================================"
break
;;

"创建验证人")
echo "============================================================"
echo "节点状态为false的时候继续下一步!"
echo "节点状态 = $(curl -s localhost:26657/status)"
echo "============================================================"
               
ollod tx staking create-validator \
  --amount 1000000utollo \
  --from $OLLOWALLET \
  --commission-max-change-rate "0.05" \
  --commission-max-rate "0.20" \
  --commission-rate "0.05" \
  --min-self-delegation "1" \
  --pubkey $(ollod tendermint show-validator) \
  --moniker $OLLONODE \
  --chain-id $OLLOCHAIN \
  --gas 300000 \
  -y
break
;;

"钱包余额")
echo "============================================================"
echo "节点名称: $OLLONODE"
echo "钱包地址: $OLLOADDRWALL" 
echo "钱包余额: $(ollod query bank balances $OLLOADDRWALL)"
echo "============================================================"
break
;;

"查看验证人") 
echo "============================================================"
echo "Account request: $(ollod q auth account $(ollod keys show $OLLOADDRWALL -a) -o text)"
echo "Validator info: $(ollod q staking validator $OLLOVAL)"
echo "============================================================"
break
;;

"水龙头获得测试币")
request=$request
echo "============================================================"
echo "进入Ollo Discord https://discord.gg/u7EeUue7 的 #testnet-faucet 频道"
echo "============================================================"
echo -e "复制粘贴 \033[32m !request $OLLOADDRWALL \033[37m"
echo "============================================================"
break
;;

"节点日志")
journalctl -u ollod -f -o cat
break
;;

"删除节点")
systemctl stop ollod
systemctl disable ollod
rm /etc/systemd/system/ollod.service
rm -r .ollo
break
;;

"退出")
exit
;;

*) echo "invalid option $REPLY";;
esac
done
done
