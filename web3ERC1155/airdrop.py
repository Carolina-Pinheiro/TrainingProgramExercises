from web3 import Web3
import json

# Global Variables
COLLECTION = "0x497a9A79e82e6fC0FF10a16f6F75e6fcd5aE65a8"
WEB3_PROVIDER_URL="http://127.0.0.1:8545"
CONTRACT_ABI = "abi/abiRagnarok.json"
BLOCK_NUMBER_LIMIT = 14672642 #15662642
CONTRACT_CREATION_BLOCK= 14662642

def main():
    # Read data from JSON
    with open('out/output.json') as f:
        dataDictionarySorted = json.load(f)
    
    # Get list of owners
    dictOfOwners = getOwners(dataDictionarySorted)

    #Airdrop tokens to users
    airdrop(dictOfOwners)


def airdrop(dictOfOwners):
    # Connect to network
    w3 = Web3(Web3.HTTPProvider(WEB3_PROVIDER_URL)) 
    assert(w3.isConnected())

    # Deploy contract
    (abi, bytecode) = getABIandBytecode('contracts/out/ThreeSigmaNFT.sol/ThreeSigmaNFT.json')
    nftContract = w3.eth.contract(abi=abi, bytecode = bytecode)
    tx_hash = nftContract.constructor().transact()
        # wait for contract to be mined
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    nftContract = w3.eth.contract(
            address=tx_receipt.contractAddress,
            abi=abi )

    # Make transaction
    owner = list(dictOfOwners.keys())[1]

    #returnData = nftContract.functions.airdropSingle(owner, dictOfOwners[owner][0]).call()
    #tx_receipt = w3.eth.wait_for_transaction_receipt(returnData)

    #returnData = nftContract.functions.airdropSingle(owner, dictOfOwners[owner][1]).call()
    #returnData = nftContract.functions.airdropSingle(owner, 5).transact()
    #tx_receipt = w3.eth.wait_for_transaction_receipt(returnData)
    for i in range(len(dictOfOwners.keys())):
        owner = list(dictOfOwners.keys())[i]
        print(type(owner))
        print(type(dictOfOwners[owner][0]))
        nftContract.functions.airdropBatch(owner, dictOfOwners[owner]).transact()
        print(i)
    print("done")
    print(nftContract.functions.balanceOf(owner).call())


# Creates the dictionary of owners and their number of NFT owned
#
def getOwners(dataDictionary):
    owners = {} # key is address, value is number of NFT owned
    tokenID = 0
    # Get last owner of the nftKeyID
    for keyNFTid in dataDictionary.keys():
        listTransactionsNFT = dataDictionary[keyNFTid]

        # Append last owner based on the block number
        #TODO: check for the block number
        key = listTransactionsNFT[list(listTransactionsNFT.keys())[-1]][-1]
        
        # Check is it is a previous owner or not
        if key not in owners:
            owners[key] = [tokenID]  # new owner
            tokenID += 1
        else:
            owners[key].append(tokenID)
            tokenID += 1
    
    return owners


# Returns the ABI inside the json file in the "filePath"
# 
def getABIandBytecode(filePath):
    with open(filePath) as f:
        info_json = json.load(f)
    return(info_json["abi"], info_json["bytecode"]["object"])

if __name__ == "__main__":
    main()