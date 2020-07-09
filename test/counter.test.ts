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

const { BN } = require("@openzeppelin/test-helpers");

const CounterModuleV1 = contract.fromArtifact("CounterModuleV1");
const CounterModuleV2 = contract.fromArtifact("CounterModuleV2");
const GSNV1Adapter = contract.fromArtifact("GSNV1Adapter");
const IRelayHub = contract.fromArtifact("IRelayHub");

describe("GSNRecipient", async () => {
  let counterModuleV1Instance: CounterModuleV1Instance;
  let counterModuleV2Instance: CounterModuleV2Instance;
  let gsnV1AdapterInstance: GSNV1AdapterInstance;
  let irelayHubInstance: IRelayHubInstance;

  before(async () => {
    await deployRelayHub(web3, { from: owner });
  });

  context("when called directly", async () => {
    beforeEach(async () => {
      counterModuleV1Instance = await CounterModuleV1.new();
      counterModuleV2Instance = await CounterModuleV2.new();

      // @ts-ignore
      gsnV1AdapterInstance = await Recipient.new();

      await gsnV1AdapterInstance.initilize(forwarder, { from: owner });

      await gsnV1AdapterInstance.setTarget(
        "0xe8927fbc",
        "increase",
        // @ts-ignore
        counterModuleV1Instance.address,
        {
          from: owner,
        },
      );

      // await gsnV1AdapterInstance.setTarget(
      //   "0xe8927fbc",
      //   "increase",
      //   // @ts-ignore
      //   counterModuleV2Instance.address,
      //   {
      //     from: owner,
      //   },
      // );

      irelayHubInstance = await IRelayHub.at(
        "0xD216153c06E857cD7f72665E0aF1d7D82172F494",
      );

      // @ts-ignore
      await fundRecipient(web3, { recipient: gsnV1AdapterInstance.address });
    });

    // it("should increase counter in CounterModuleV1", async function () {
    //   const gsnV1AdapterPreBalance = await irelayHubInstance.balanceOf(
    //     // @ts-ignore
    //     gsnV1AdapterInstance.address,
    //   );

    //   const senderPreBalance = await web3.eth.getBalance(_);

    //   const {
    //     receipt: { from },
    //     // @ts-ignore
    //   } = await gsnV1AdapterInstance.sendTransaction({
    //     from: _,
    //     data: "0xe8927fbc",
    //     useGSN: false,
    //   });

    //   const value = await counterModuleV1Instance.getValue();

    //   const gsnV1AdapterPostBalance = await irelayHubInstance.balanceOf(
    //     // @ts-ignore
    //     gsnV1AdapterInstance.address,
    //   );

    //   const senderPostBalance = await web3.eth.getBalance(_);

    //   expect(gsnV1AdapterPreBalance).to.be.bignumber.equal(
    //     gsnV1AdapterPostBalance,
    //   );
    //   expect(senderPreBalance).to.be.bignumber.above(senderPostBalance);
    //   expect(value).to.be.bignumber.equal(new BN(1));
    //   expect(from.toUpperCase()).equal(_.toUpperCase());
    // });

    // it("should set counter in CounterModuleV2", async function () {
    //   const gsnV1AdapterPreBalance = await irelayHubInstance.balanceOf(
    //     // @ts-ignore
    //     gsnV1AdapterInstance.address,
    //   );

    //   const senderPreBalance = await web3.eth.getBalance(_);

    //   const {
    //     receipt: { from },
    //     // @ts-ignore
    //   } = await gsnV1AdapterInstance.sendTransaction({
    //     from: _,
    //     data: "0xe8927fbc",
    //     useGSN: false,
    //   });

    //   const value = await counterModuleV2Instance.getValue();

    //   const gsnV1AdapterPostBalance = await irelayHubInstance.balanceOf(
    //     // @ts-ignore
    //     gsnV1AdapterInstance.address,
    //   );

    //   const senderPostBalance = await web3.eth.getBalance(_);

    //   expect(gsnV1AdapterPreBalance).to.be.bignumber.equal(
    //     gsnV1AdapterPostBalance,
    //   );
    //   expect(senderPreBalance).to.be.bignumber.above(senderPostBalance);
    //   expect(value).to.be.bignumber.equal(new BN(1));
    //   expect(from.toUpperCase()).equal(_.toUpperCase());
    // });
  });

  // context("when relay-called", async () => {
  //   beforeEach(async function () {
  //     counterModuleV1Instance = await CounterModuleV1.new();
  //     counterModuleV2Instance = await CounterModuleV2.new();

  //     // @ts-ignore
  //     gsnV1AdapterInstance = await Recipient.new();

  //     await gsnV1AdapterInstance.initilize(forwarder, { from: owner });

  //     irelayHubInstance = await IRelayHub.at(
  //       "0xD216153c06E857cD7f72665E0aF1d7D82172F494",
  //     );

  //     // @ts-ignore
  //     await fundRecipient(web3, { recipient: gsnV1AdapterInstance.address });
  //   });

  //   it("should increase counter in CounterModuleV1", async function () {
  //     const gsnV1AdapterPreBalance = await irelayHubInstance.balanceOf(
  //       // @ts-ignore
  //       gsnV1AdapterInstance.address,
  //     );

  //     const senderPreBalance = await web3.eth.getBalance(_);

  //     const {
  //       receipt: { from },
  //       // @ts-ignore
  //     } = await gsnV1AdapterInstance.sendTransaction({
  //       from: _,
  //       data: "0xe8927fbc",
  //       useGSN: true,
  //     });

  //     const value = await counterModuleV1Instance.getValue();

  //     const gsnV1AdapterPostBalance = await irelayHubInstance.balanceOf(
  //       // @ts-ignore
  //       gsnV1AdapterInstance.address,
  //     );

  //     const senderPostBalance = await web3.eth.getBalance(_);

  //     expect(gsnV1AdapterPreBalance).to.be.bignumber.equal(
  //       gsnV1AdapterPostBalance,
  //     );
  //     expect(senderPreBalance).to.be.bignumber.above(senderPostBalance);
  //     expect(value).to.be.bignumber.equal(new BN(1));
  //     expect(from.toUpperCase()).equal(_.toUpperCase());
  //   });

  //   it("should set counter in CounterModuleV2", async function () {
  //     const gsnV1AdapterPreBalance = await irelayHubInstance.balanceOf(
  //       // @ts-ignore
  //       gsnV1AdapterInstance.address,
  //     );

  //     const senderPreBalance = await web3.eth.getBalance(_);

  //     const {
  //       receipt: { from },
  //       // @ts-ignore
  //     } = await gsnV1AdapterInstance.sendTransaction({
  //       from: _,
  //       data: "0xe8927fbc",
  //       useGSN: true,
  //     });

  //     const value = await counterModuleV2Instance.getValue();

  //     const gsnV1AdapterPostBalance = await irelayHubInstance.balanceOf(
  //       // @ts-ignore
  //       gsnV1AdapterInstance.address,
  //     );

  //     const senderPostBalance = await web3.eth.getBalance(_);

  //     expect(gsnV1AdapterPreBalance).to.be.bignumber.equal(
  //       gsnV1AdapterPostBalance,
  //     );
  //     expect(senderPreBalance).to.be.bignumber.above(senderPostBalance);
  //     expect(value).to.be.bignumber.equal(new BN(1));
  //     expect(from.toUpperCase()).equal(_.toUpperCase());
  //   });
  // });

  // context("when relay-called from non trusted forwarder", async () => {
  //   beforeEach(async function () {
  //     counterModuleV1Instance = await CounterModuleV1.new();

  //     gsnV1AdapterInstance = await GSNV1Adapter.new();

  //     await gsnV1AdapterInstance.initilize(
  //       fakeForwarder,
  //       // @ts-ignore
  //       { from: owner },
  //     );

  //     irelayHubInstance = await IRelayHub.at(
  //       "0xD216153c06E857cD7f72665E0aF1d7D82172F494",
  //     );

  //     // @ts-ignore
  //     await fundRecipient(web3, { recipient: gsnV1AdapterInstance.address });
  //   });

  //   // TODO Change Error Capture
  //   it("should not increase counter in CounterModuleV1", async function () {
  //     try {
  //       const recipientPreBalance = await irelayHubInstance.balanceOf(
  //         // @ts-ignore
  //         gsnV1AdapterInstance.address,
  //       );
  //       const senderPreBalance = await web3.eth.getBalance(_);

  //       const {
  //         receipt: { from },
  //         // @ts-ignore
  //       } = await gsnV1AdapterInstance.sendTransaction({
  //         from: _,
  //         data: "0xe8927fbc",
  //         useGSN: true,
  //       });

  //       const value = await counterModuleV1Instance.getValue();

  //       const recipientPostBalance = await irelayHubInstance.balanceOf(
  //         // @ts-ignore
  //         gsnV1AdapterInstance.address,
  //       );

  //       const senderPostBalance = await web3.eth.getBalance(_);

  //       throw null;
  //     } catch (err) {
  //       expect(err, "Expected a revert but did not get one");
  //     }
  //   });
  // });
});
