# -------------------------------------------------------
# 07/02/2023
# GOAL:  Fetch transfer history of a NFT collection
# 
# Details:
# 1) when a NFT is transfered it will emit a Transfer event
# 2) fetch the transfer history and compile it in a JSON file
# 3) json file
#       - NFT IDs as keys
#       - list of the owners that held with the date where that NFT was transfered by cronological order
# 4) NFT can be transfered more than once in the same block
# 5) make code as modular as possible (i.e. easy to implement to another ERC1155 collection)
# 6) collection intended -> https://etherscan.io/address/0x497a9a79e82e6fc0ff10a16f6f75e6fcd5ae65a8#code
# -------------------------------------------------------

# Imports
from web3 import Web3
import json

# Global Variables
COLLECTION = "0x497a9A79e82e6fC0FF10a16f6F75e6fcd5aE65a8" 
WEB3_PROVIDER_URL="https://mainnet.infura.io/v3/f197043f46a0400980b4198e295c2346" 
CONTRACT_ABI = "abi/abiRagnarok.json" # could be fecthed from etherscan with an API
CONTRACT_CREATION_BLOCK= 14662642 # could be fecthed from etherscan with an API

def main():
    # Connect to network
    w3 = Web3(Web3.HTTPProvider(WEB3_PROVIDER_URL))
    collectionContract = w3.eth.contract(address=COLLECTION, abi=getABI(CONTRACT_ABI))

    # Get latest block 
    latestBlock = w3.eth.block_number #  CONTRACT_CREATION_BLOCK + 30000  # 
    
    # Prepare for fetching loop
    interval = 10000
    eventsSingle= []
    eventsBatch= []

    # Fetch events
    for startBlock in range(CONTRACT_CREATION_BLOCK, latestBlock+interval, interval):
        print(startBlock,startBlock + interval ,latestBlock)
        eventsSingle.append(collectionContract.events.TransferSingle.getLogs(
                            fromBlock=startBlock, 
                            toBlock=startBlock + interval )
                            )
        eventsBatch.append(collectionContract.events.TransferBatch.getLogs(
                    fromBlock=startBlock, 
                    toBlock=startBlock + interval )
                    )

    # Sort Data
    dataDictionary = sortEventToDictionary(eventsSingle, eventsBatch, {})
    dataDictionarySorted = sortDictionaryLogIndex(dataDictionary)

    # Save
    saveToJSON(dataDictionarySorted, "out/output.json")


#   Sorts the events into a dictionary according to its ID, address & block number
#
def sortEventToDictionary(eventsSingle,eventsBatch, dataDictionary) -> dict:
    for event in eventsSingle:
        if len(event) != 0:
            for eventId in range(len(event)):
                saveEntry(dataDictionary, 
                            event[eventId].args.id, 
                            event[eventId].args.to, 
                            event[eventId].blockNumber,
                            event[eventId].logIndex)

    for event in eventsBatch:
        if len(event) != 0:
            for eventId in range(len(event)):
                for id in event[eventId].args.ids:
                    saveEntry(dataDictionary, 
                                id, 
                                event[eventId].args.to, 
                                event[eventId].blockNumber,
                                event[eventId].logIndex)
    
    return dataDictionary


# Sort Dictionary according to log index
#
def sortDictionaryLogIndex(dataDictionary):
    dataDictionary= dict(sorted(dataDictionary.items())) #sorted by nftkey id
    for keyNFTid in dataDictionary.keys():
        for blockNumber in dataDictionary[keyNFTid].keys():
            sortedDict = dict(sorted(dataDictionary[keyNFTid][blockNumber].items(), key=lambda item: item[1])) #sort based on the log index
            dataDictionary[keyNFTid][blockNumber] = list(sortedDict.keys()) # save only the ordered keys to the dictionary
    return dataDictionary


# Saves a new entry to the dictionary
#   	newer entries are added to the end of the list of the corresponding key
def saveEntry(dataDictionary, keyNFTid, owner, blockNumber, transactionIndex):
    # if there is already a nft key, add to it
    if keyNFTid in dataDictionary:
        # if the blockNumber is already present, add to it
        if blockNumber in dataDictionary[keyNFTid]:
            dataDictionary[keyNFTid][blockNumber][owner] = transactionIndex
        # else create a new entry for the blockNumber
        else:
            dataDictionary[keyNFTid][blockNumber] = {owner: transactionIndex}
    # else, add the new nft key
    else:
        dataDictionary[keyNFTid] =  {blockNumber: {owner: transactionIndex}}


# Returns the ABI inside the json file in the "filePath"
# 
def getABI(filePath):
    with open(filePath) as f:
        info_json = json.load(f)
    return(info_json["result"])


# Saves "data" of the type dict to a json file in the "filePath"
#   the file in "filePath" will be created if it is non-existent
def saveToJSON(data, filePath):
    with open(filePath, "w") as outfile:
        json.dump(data, outfile, indent=3)


# Run the main function
if __name__ == "__main__":
    main()