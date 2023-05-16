from web3 import Web3

# Set environment variables
WEB3_PROVIDER_URL="https://goerli.infura.io/v3/f197043f46a0400980b4198e295c2346"

# Connect to network
w3 = Web3(Web3.HTTPProvider(WEB3_PROVIDER_URL))

# Set address of existing contract
contract_address = '0x907b1b36e993F922a023ee7e49FA4D68f1Bd4C28'
to_address = '0x2C4aD1D64adB665a53A55730972F4657E9CA3bf6'
my_address = '0x452D4c2F74D4AcC8F569a4A66077E89dd49C2e0b'
private = '756e2b38c4ac27a765e7265a1d6b75c897f51716492072332df0994b6e579afb'
lopes = '0x2C4aD1D64adB665a53A55730972F4657E9CA3bf6'

#contract_instance = w3.eth.contract(address=contract_address)

transaction = {
     'to': contract_address,
     'nonce': w3.eth.get_transaction_count(my_address),
     'value': w3.toWei(0.01,'ether'),
     'data': w3.toHex(text='buyItem(address) '+ my_address),
     'gas': 32000,
     'gasPrice': w3.toWei(100,'gwei'),
}

signed = w3.eth.account.sign_transaction(transaction, private)
w3.eth.send_raw_transaction(signed.rawTransaction)

print('Success')
print("Transaction Hash:", w3.toHex(w3.keccak(signed.rawTransaction)))