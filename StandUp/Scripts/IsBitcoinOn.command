#!/bin/sh

#  IsBitcoinOn.command
#  StandUp
#
#  Created by Peter on 19/11/19.
#  Copyright © 2019 Peter. All rights reserved.
~/StandUp/BitcoinCore/$PREFIX/bin/bitcoin-cli getblockchaininfo
echo "Done"
exit
