struct Contributor:
    userAddress: address
    contribution: wei_value

owner: public(address)
target: public(wei_value)
endTime: public(timestamp)
nextContributorIndex: int128
contributors: map(int128, Contributor)
    
@public 
def __init__(_target: wei_value, _owner: address, _duration: timedelta):
    self.owner = _owner
    self.target = _target
    self.endTime = block.timestamp + _duration       
    
      
@public
@payable
def contribute():
    assert block.timestamp < self.endTime, "deadline not yet met"
    nci: int128 = self.nextContributorIndex
    self.contributors[nci] = Contributor({userAddress: msg.sender, contribution: msg.value})
    self.nextContributorIndex = nci + 1


@public
def collect():
    assert self.balance >= self.target
    assert msg.sender == self.owner
    selfdestruct(self.owner)
        
        
@public
def refund():
    assert block.timestamp > self.endTime
    assert self.balance < self.target

    idx: int128 = self.nextContributorIndex

    for i in range(idx, idx + 30):
        if i >= self.nextContributorIndex:
            return
        send(self.contributors[i].userAddress, self.contributors[i].contribution)
        clear(self.contributors[i])
    
@public
def Unreserved_balance() -> wei_value:
    return self.balance