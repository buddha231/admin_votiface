from brownie import Voting

voting = Voting[-1]


def read_contract():
    print(voting.voters_count())


def get_candidates():
    print(voting.getCandidates())


def main():
    get_candidates()
