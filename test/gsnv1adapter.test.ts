import {
  CounterModuleV1Instance,
  CounterModuleV2Instance,
  GSNV1AdapterInstance,
  IRelayHubInstance,
} from "../types/contracts";

const { expect } = require("chai");

const {
  accounts: [owner, forwarder, fakeForwarder, _],
  accounts,
  contract,
  web3,
} = require("@openzeppelin/test-environment");

const { deployRelayHub, fundRecipient } = require("@openzeppelin/gsn-helpers");

const { BN, ether, expectRevert } = require("@openzeppelin/test-helpers");

const {
  abi: CounterModuleV1Abi,
} = require("../build/contracts/CounterModuleV1.json");
const {
  abi: CounterModuleV2Abi,
} = require("../build/contracts/CounterModuleV2.json");
const {
  abi: GSNV1AdapterAbi,
} = require("../build/contracts/GSNV1Adapter.json");
const { abi: IRelayHubAbi } = require("../build/contracts/IRelayHub.json");

const CounterModuleV1 = contract.fromArtifact("CounterModuleV1");
const CounterModuleV2 = contract.fromArtifact("CounterModuleV2");
const GSNV1Adapter = contract.fromArtifact("GSNV1Adapter");
const IRelayHub = contract.fromArtifact("IRelayHub");

describe("GSNV1Adapter", async () => {
  let counterModuleV1Instance: CounterModuleV1Instance;
  let counterModuleV2Instance: CounterModuleV2Instance;
  let gsnV1AdapterInstance: GSNV1AdapterInstance;
  let irelayHubInstance: IRelayHubInstance;

  let counterModuleV1Web3Instance: any;
  let counterModuleV2Web3Instance: any;
  let gsnV1AdapterWeb3Instance: any;
  let irelayHubWeb3Instance: any;

  beforeEach(async () => {
    await deployRelayHub(web3, { from: owner });

    counterModuleV1Instance = await CounterModuleV1.new();
    counterModuleV2Instance = await CounterModuleV2.new();
    // @ts-ignore
    gsnV1AdapterInstance = await GSNV1Adapter.new();

    irelayHubInstance = await IRelayHub.at(
      "0xD216153c06E857cD7f72665E0aF1d7D82172F494",
    );

    counterModuleV1Web3Instance = new web3.eth.Contract(
      CounterModuleV1Abi,
      // @ts-ignore
      counterModuleV1Instance.address,
    );

    counterModuleV2Web3Instance = new web3.eth.Contract(
      CounterModuleV2Abi,
      // @ts-ignore
      counterModuleV2Instance.address,
    );

    gsnV1AdapterWeb3Instance = new web3.eth.Contract(
      GSNV1AdapterAbi,
      // @ts-ignore
      gsnV1AdapterInstance.address,
    );

    irelayHubWeb3Instance = new web3.eth.Contract(
      IRelayHubAbi,
      // @ts-ignore
      irelayHubInstance.address,
    );

    await gsnV1AdapterInstance.initilize__0xb373a41f(forwarder, owner, {
      from: owner,
    });

    await gsnV1AdapterInstance.setTarget__0xb373a41f(
      "0xe8927fbc",
      "CounterModuleV1__increase",
      // @ts-ignore
      counterModuleV1Instance.address,
      {
        from: owner,
      },
    );

    await gsnV1AdapterInstance.setTarget__0xb373a41f(
      "0x55241077",
      "CounterModuleV2__setValue",
      // @ts-ignore
      counterModuleV2Instance.address,
      {
        from: owner,
      },
    );

    // @ts-ignore
    await fundRecipient(web3, { recipient: gsnV1AdapterInstance.address });
  });

  context("when called directly", async () => {
    it("should increase counter in CounterModuleV1", async function () {
      const gsnV1AdapterPreBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      const senderPreBalance = await web3.eth.getBalance(_);

      const {
        receipt: { from },
        // @ts-ignore
      } = await gsnV1AdapterInstance.sendTransaction({
        from: _,
        data: counterModuleV1Web3Instance.methods.increase().encodeABI(),
        useGSN: false,
      });

      const value = await counterModuleV1Instance.getValue();
      const sender = await counterModuleV1Instance.getSender();

      const gsnV1AdapterPostBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      const senderPostBalance = await web3.eth.getBalance(_);

      expect(gsnV1AdapterPreBalance).to.be.bignumber.equal(
        gsnV1AdapterPostBalance,
      );
      expect(senderPreBalance).to.be.bignumber.above(senderPostBalance);
      expect(value).to.be.bignumber.equal(new BN(1));
      expect(from.toUpperCase()).equal(_.toUpperCase());
      expect(sender.toUpperCase()).equal(_.toUpperCase());
    });

    it("should set counter in CounterModuleV2", async function () {
      const gsnV1AdapterPreBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      const senderPreBalance = await web3.eth.getBalance(_);

      const {
        receipt: { from },
        // @ts-ignore
      } = await gsnV1AdapterInstance.sendTransaction({
        from: _,
        data: counterModuleV2Web3Instance.methods.setValue("1").encodeABI(),
        useGSN: false,
      });

      const value = await counterModuleV2Instance.getValue();
      const sender = await counterModuleV2Instance.getSender();

      const gsnV1AdapterPostBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      const senderPostBalance = await web3.eth.getBalance(_);

      expect(gsnV1AdapterPreBalance).to.be.bignumber.equal(
        gsnV1AdapterPostBalance,
      );
      expect(senderPreBalance).to.be.bignumber.above(senderPostBalance);
      expect(value).to.be.bignumber.equal(new BN(1));
      expect(from.toUpperCase()).equal(_.toUpperCase());
      expect(sender.toUpperCase()).equal(_.toUpperCase());
    });

    it("should deposit funds to RelayHub", async function () {
      const gsnV1AdapterPreBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      const {
        receipt: { from },
        // @ts-ignore
      } = await gsnV1AdapterInstance.sendTransaction({
        from: _,
        data: gsnV1AdapterWeb3Instance.methods
          .deposit__0xb373a41f()
          .encodeABI(),
        value: ether("1"),
        useGSN: false,
      });

      const gsnV1AdapterPostBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      expect(gsnV1AdapterPostBalance).to.be.bignumber.equal(ether("2"));
      expect(from.toUpperCase()).equal(_.toUpperCase());
    });

    it("should withdraw funds from RelayHub", async function () {
      const gsnV1AdapterPreBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      const _PreBalance = await web3.eth.getBalance(_);

      const {
        receipt: { from },
        // @ts-ignore
      } = await gsnV1AdapterInstance.sendTransaction({
        from: owner,
        data: gsnV1AdapterWeb3Instance.methods
          .withdraw__0xb373a41f(ether("1").toString(), _)
          .encodeABI(),
        useGSN: false,
      });

      const _PostBalance = await web3.eth.getBalance(_);

      const gsnV1AdapterPostBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      expect(_PostBalance).to.be.bignumber.equal(
        new BN(_PreBalance).add(ether("1")),
      );
      expect(gsnV1AdapterPostBalance).to.be.bignumber.equal(ether("0"));
      expect(from.toUpperCase()).equal(owner.toUpperCase());
    });

    it("should get manager role", async function () {
      const managerRole = await gsnV1AdapterInstance.getManagerRole__0xb373a41f();

      expect(managerRole).equal(
        "0x241ecf16d79d0f8dbfb92cbc07fe17840425976cf0667f022fe9877caa831b08",
      );
    });

    it("should get target name", async function () {
      const targetName = await gsnV1AdapterInstance.getTargetName__0xb373a41f(
        "0xe8927fbc",
      );

      expect(targetName).equal("CounterModuleV1__increase");
    });

    it("should get target address", async function () {
      const targetAddress = await gsnV1AdapterInstance.getTargetAddress__0xb373a41f(
        "0xe8927fbc",
      );

      // @ts-ignore
      expect(targetAddress).equal(counterModuleV1Instance.address);
    });
  });

  context("when relay-called", async () => {
    it("should increase counter in CounterModuleV1", async function () {
      const gsnV1AdapterPreBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      const senderPreBalance = await web3.eth.getBalance(_);

      const {
        receipt: { from },
        // @ts-ignore
      } = await gsnV1AdapterInstance.sendTransaction({
        from: _,
        data: counterModuleV1Web3Instance.methods.increase().encodeABI(),
        useGSN: true,
      });

      const value = await counterModuleV1Instance.getValue();
      const sender = await counterModuleV1Instance.getSender();

      const gsnV1AdapterPostBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      const senderPostBalance = await web3.eth.getBalance(_);

      expect(gsnV1AdapterPreBalance).to.be.bignumber.above(
        gsnV1AdapterPostBalance,
      );
      expect(senderPreBalance).to.be.bignumber.equal(senderPostBalance);
      expect(value).to.be.bignumber.equal(new BN(1));
      expect(from.toUpperCase()).equal(accounts[9].toUpperCase());
      expect(sender.toUpperCase()).equal(_.toUpperCase());
    });

    it("should set counter in CounterModuleV2", async function () {
      const gsnV1AdapterPreBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      const senderPreBalance = await web3.eth.getBalance(_);

      const {
        receipt: { from },
        // @ts-ignore
      } = await gsnV1AdapterInstance.sendTransaction({
        from: _,
        data: counterModuleV2Web3Instance.methods.setValue("1").encodeABI(),
        useGSN: true,
      });

      const value = await counterModuleV2Instance.getValue();
      const sender = await counterModuleV2Instance.getSender();

      const gsnV1AdapterPostBalance = await irelayHubInstance.balanceOf(
        // @ts-ignore
        gsnV1AdapterInstance.address,
      );

      const senderPostBalance = await web3.eth.getBalance(_);

      expect(gsnV1AdapterPreBalance).to.be.bignumber.above(
        gsnV1AdapterPostBalance,
      );
      expect(senderPreBalance).to.be.bignumber.equal(senderPostBalance);
      expect(value).to.be.bignumber.equal(new BN(1));
      expect(from.toUpperCase()).equal(accounts[9].toUpperCase());
      expect(sender.toUpperCase()).equal(_.toUpperCase());
    });
  });

  context("when relay-called from fake forwarder", async () => {
    it("should not increase counter in CounterModuleV1", async function () {
      try {
        const {
          receipt: { from },
          // @ts-ignore
        } = await gsnV1AdapterInstance.sendTransaction({
          from: _,
          data: counterModuleV1Web3Instance.methods.increase().encodeABI(),
          useGSN: true,
        });

        throw null;
      } catch (err) {
        expect(err, "Expected a revert but did not get one");
      }
    });
  });
});
