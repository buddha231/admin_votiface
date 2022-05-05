import time
from brownie import accounts, config, Voting

account = accounts.add(
    "96e61ea5a49f785830522f4e1f195dfde1fab97ee816a62202168e597bdcbb70")

contract = Voting[-1]


def remove_right_to_vote():
    contract.removeRightToVote(
        accounts.at("0x0Cc688CC55b1BAf592476DCFd5e497B1C6602C9c"), {"from": account})
    # for i in accounts:
    #     contract.removeRightToVote(i, {"from": account})


def give_right_to_vote():
    account_biraj = accounts.add(
        "ed82137b52b85d658df090db8fe76d99596ef127eeebf80cfbbd0ed76c2395da")
    contract.giveRightToVote(
        account_biraj, "123123123", "1", {"from": account})
    # for i in accounts:
    #     try:
    #         contract.giveRightToVote(i, {"from": account})
    #     except:
    #         pass


def add_candidates():

    contract.addCandidates(
        [
            ["fucker", "congress"],
        ],
        {"from": account}
    )


def main():
    # remove_right_to_vote()
    give_right_to_vote()
    # add_candidates()


main()
