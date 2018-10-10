require 'json'

describe "Ethereum common tests" do
  before { configure_chain_id 1 }

  it "passes all the transaction tests" do
    [
      'spec/fixtures/ethereum_tests/TransactionTests/ttTransactionTest.json',
      'spec/fixtures/ethereum_tests/TransactionTests/EIP155/ttTransactionTestVRule.json',
      'spec/fixtures/ethereum_tests/TransactionTests/EIP155/ttTransactionTest.json',
      'spec/fixtures/ethereum_tests/TransactionTests/EIP155/ttTransactionTestEip155VitaliksTests.json',
    ].each do |file_path|
      JSON.parse(File.read file_path).each do |name, json|
        next unless json_tx = json['transaction']

        tx = Eth::Tx.decode json['rlp']

        expect(tx.from.downcase).to eq "0x#{json['sender']}"
        expect(tx.v).to eq json_tx['v'].to_i(16)
        expect(tx.r).to eq json_tx['r'].to_i(16)
        expect(tx.s).to eq json_tx['s'].to_i(16)
        expect(tx.value).to eq json_tx['value'].to_i(16)
        expect(tx.nonce).to eq json_tx['nonce'].to_i(16)
        expect(tx.gas_price).to eq json_tx['gasPrice'].to_i(16)
        expect(tx.gas_limit).to eq json_tx['gasLimit'].to_i(16)
      end
    end
  end
end
