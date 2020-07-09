import {
  CounterModuleV1Instance,
  GSNV1AdapterInstance,
  IRelayHubInstance,
} from "../types/contracts";

const { expect } = require("chai");

const {
  accounts: [owner, _],
  accounts,
  contract,
  web3,
} = require("@openzeppelin/test-environment");

const { deployRelayHub, fundRecipient } = require("@openzeppelin/gsn-helpers");

const { BN } = require("@openzeppelin/test-helpers");

const CounterModuleV1 = contract.fromArtifact("CounterModuleV1");
const GSNV1Adapter = contract.fromArtifact("GSNV1Adapter");
const IRelayHub = contract.fromArtifact("IRelayHub");

describe("GSNRecipient", async () => {
  let counterModuleV1Instance: CounterModuleV1Instance;
  let gsnV1AdapterInstance: GSNV1AdapterInstance;
  let irelayHubInstance: IRelayHubInstance;

  before(async function () {
    await deployRelayHub(web3, { from: owner });
  });

  context("when called directly", function () {
    beforeEach(async function () {
      counterModuleV1Instance = await CounterModuleV1.new();

      gsnV1AdapterInstance = await GSNV1Adapter.new();

      await gsnV1AdapterInstance.initilize(
        owner,
        // @ts-ignore
        counterModuleV1Instance.address,
        { from: owner },
      );

      irelayHubInstance = await IRelayHub.at(
        "0xD216153c06E857cD7f72665E0aF1d7D82172F494",
      );

      // @ts-ignore
      await fundRecipient(web3, { recipient: gsnV1AdapterInstance.address });
    });

    it("should increase counter", async function () {
      const recipientPreBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );
      const senderPreBalance = await web3.eth.getBalance(_);

      const {
        receipt: { from },
        // @ts-ignore
      } = await gsnV1AdapterInstance.sendTransaction({
        from: _,
        data: "0xe8927fbc",
        useGSN: false,
      });

      const value = await counterModuleV1Instance.value();

      const recipientPostBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      const senderPostBalance = await web3.eth.getBalance(_);

      expect(recipientPreBalance).to.be.bignumber.equal(recipientPostBalance);
      expect(senderPreBalance).to.be.bignumber.above(senderPostBalance);
      expect(value).to.be.bignumber.equal(new BN(1));
      expect(from.toUpperCase()).equal(_.toUpperCase());
    });
  });

  context("when relay-called", function () {
    beforeEach(async function () {
      counterModuleV1Instance = await CounterModuleV1.new();

      gsnV1AdapterInstance = await GSNV1Adapter.new();

      await gsnV1AdapterInstance.initilize(
        owner,
        // @ts-ignore
        counterModuleV1Instance.address,
        { from: owner },
      );

      irelayHubInstance = await IRelayHub.at(
        "0xD216153c06E857cD7f72665E0aF1d7D82172F494",
      );

      // @ts-ignore
      await fundRecipient(web3, { recipient: gsnV1AdapterInstance.address });
    });

    it("should increase counter", async function () {
      const recipientPreBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );
      const senderPreBalance = await web3.eth.getBalance(_);

      const {
        receipt: { from },
        // @ts-ignore
      } = await gsnV1AdapterInstance.sendTransaction({
        from: _,
        data: "0xe8927fbc",
        useGSN: true,
      });

      const value = await counterModuleV1Instance.value();

      const recipientPostBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      const senderPostBalance = await web3.eth.getBalance(_);

      expect(recipientPreBalance).to.be.bignumber.above(recipientPostBalance);
      expect(senderPreBalance).to.be.bignumber.equal(senderPostBalance);
      expect(value).to.be.bignumber.equal(new BN(1));
      expect(from.toUpperCase()).equal(accounts[9].toUpperCase());
    });
  });

  context("when relay-called from non trusted forwarder", function () {
    beforeEach(async function () {
      counterModuleV1Instance = await CounterModuleV1.new();

      gsnV1AdapterInstance = await GSNV1Adapter.new();

      await gsnV1AdapterInstance.initilize(
        _,
        // @ts-ignore
        counterModuleV1Instance.address,
        { from: owner },
      );

      irelayHubInstance = await IRelayHub.at(
        "0xD216153c06E857cD7f72665E0aF1d7D82172F494",
      );

      // @ts-ignore
      await fundRecipient(web3, { recipient: gsnV1AdapterInstance.address });
    });

    // TODO Change Error Capture
    it("should increase counter", async function () {
      try {
        const recipientPreBalance = await irelayHubInstance.balanceOf(
          // @ts-ignore
          gsnV1AdapterInstance.address,
        );
        const senderPreBalance = await web3.eth.getBalance(_);

        const {
          receipt: { from },
          // @ts-ignore
        } = await gsnV1AdapterInstance.sendTransaction({
          from: _,
          data: "0xe8927fbc",
          useGSN: true,
        });

        const value = await counterModuleV1Instance.value();

        const recipientPostBalance = await irelayHubInstance.balanceOf(
          // @ts-ignore
          gsnV1AdapterInstance.address,
        );

        const senderPostBalance = await web3.eth.getBalance(_);

        throw null;
      } catch (err) {
        expect(err, "Expected a revert but did not get one");
      }
    });
  });
});
