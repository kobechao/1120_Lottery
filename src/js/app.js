App = {
  web3Provider: null,
  originProvider: null,
  contracts: {},
  anotherWeb3: null,

  init: function () {
    return App.initWeb3();
  },

  initWeb3: function () {
    // Initialize web3 and set the provider to the testRPC.
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // set the provider you want from Web3.providers
      App.web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:8545');
      web3 = new Web3(App.web3Provider);
    }

    App.anotherWeb3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:8545'));

    return App.initContract();
  },

  initContract: function () {
    $.getJSON('Lottery.json', function (data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract.
      let LotteryArtifact = data;
      App.contracts.Lottery = TruffleContract(LotteryArtifact);

      // Set the provider for our contract.
      App.contracts.Lottery.setProvider(App.web3Provider);

      // Use our contract to retieve and mark the adopted pets.
      return App.initInfo();
    });

    return App.bindEvents();
  },

  bindEvents: function () {
    $(document).on('click', '#bet0', { num: 1 }, App.handleBetClick);
    $(document).on('click', '#bet1', { num: 2 }, App.handleBetClick);
    $(document).on('click', '#bet2', { num: 3 }, App.handleBetClick);
  },

  handleBetClick: function (event) {
    console.log(event.data.num);
    let num = event.data.num;
    let lotteryInstance;
    App.contracts.Lottery.deployed().then(function (instance) {
      lotteryInstance = instance;
      console.log(accounts)
      let betNum = $(`#betVal${num}`).val();
      console.log(`#betVal${num}`)
      console.log(betNum)
      return lotteryInstance.bet(num, { from: accounts[0], value: betNum * 10 **18});
    }).then(result => {
      console.log(result)
    }).catch(err => {
      console.log(err)
    })
  },

  initInfo: function () {

    let lotteryInstance;

    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }

      let account = accounts[0];
      App.anotherWeb3.eth.getAccounts((err, accounts) => {

        for (let i in accounts) {
          $("#accounts").append(`
          <li>
            <span>${accounts[i]}<span><p></p>
            <span>${(App.anotherWeb3.eth.getBalance(accounts[i]) / 10 ** 18)} ETH</span>
            <br></br>
          </li>`
          )
        }
      })

      App.contracts.Lottery.deployed().then(function (instance) {
        lotteryInstance = instance;

        return Promise.all([
          lotteryInstance.getNum(1),
          lotteryInstance.getNum(2),
          lotteryInstance.getNum(3),
        ])
      }).then(data => {
        $('#index0_val').text(`${data[0][0] / 10 ** 18}`);
        $('#index1_val').text(`${data[1][0] / 10 ** 18}`);
        $('#index2_val').text(`${data[2][0] / 10 ** 18}`);

      }).catch(function (err) {
        console.log(err.message);
      });
    });
  }

};

$(function () {
  $(window).load(function () {
    App.init();
  });
});
