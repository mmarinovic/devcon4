module.exports = {
  networks: {
    development: {
      network_id: '*',
      host: 'localhost',
      port: 8545
    },
    ganache: {
      network_id: '*',
      host: 'localhost',
      port: 7545
    }
  }
};
