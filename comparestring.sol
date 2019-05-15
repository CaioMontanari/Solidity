 function hashCompareWithLengthCheck(string memory a, string memory b) pure public returns (bool) {
    if(bytes(a).length != bytes(b).length) {
        return false;
    } else {if (keccak256(bytes(a)) == keccak256(bytes(b))){
        
        return true
        ;
    }
}
}
}
