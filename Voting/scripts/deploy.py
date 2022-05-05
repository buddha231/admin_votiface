from brownie import accounts, config, Voting


def deploy_voting():
    # account = accounts.load("buddha")
    # account = accounts[0]
    account = accounts.add(
        "96e61ea5a49f785830522f4e1f195dfde1fab97ee816a62202168e597bdcbb70")
    voting = Voting.deploy(
        [
            ["buddha", "congress", "1"],  ["biraj", "maoist", "2"]
        ],
        ["congress", "maoist", "emale"],
        {"from": account, "value": 10**16}
    )


def main():
    deploy_voting()
