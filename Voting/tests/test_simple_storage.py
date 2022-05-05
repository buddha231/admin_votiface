import random
from brownie import Voting, accounts


# def test_deploy():
#     # Arrange
#     # deploy_account = accounts.load("buddha")
#     deploy_account = accounts[0]
#     voters_expected = 1

#     # Act
#     voting = Voting.deploy(
#         [
#             ["KP ba", "emale", "1"], ["prachande", "maoist", "1"]
#         ],
#         ["maoist", "congress", "emale"],
#         {"from": deploy_account}
#     )
#     assert voters_expected == voting.voters_count()


def test_give_voting_rights():
    # deploy_account = accounts.load("buddha")
    deploy_account = accounts[0]
    voters_expected = 10
    voting = Voting[-1]
    for account in accounts:
        voting.giveRightToVote(
            account, str(random.randrange(100, 1000)), "1", {
                "from": deploy_account}
        )
    total = voting.voters_count()
    assert total == voters_expected


def test_removing_voting_rights():
    # deploy_account = accounts.load("buddha")
    deploy_account = accounts[0]
    voters_expected = 0
    voting = Voting[-1]
    for account in accounts:
        try:
            voting.removeRightToVote(
                account, {"from": deploy_account}
            )
        except:
            pass
    total = voting.voters_count()
    assert total == voters_expected
