function showBalance() {
    web3.eth.getAccounts(function(error, result) {
        var address = result[0];
        web3.eth.getBalance(address, function(error, result) {
            var balance = web3.fromWei(result);
            $("#address").text(address);
            $("#balance").text(balance + " ETH");
        });
    });
}

function startApp() {
    showBalance();
}

window.addEventListener("load", function() {
    if (typeof web3 !== 'undefined') {
        web3 = new Web3(web3.currentProvider);
        startApp();
    }
    else {
        alert("Please install MetaMask Plugin!");
        window.location.href = "https://metamask.io/";
    }
});
